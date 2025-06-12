import boto3
import json
import logging
import os
from botocore.exceptions import ClientError
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

# Constants
SSM_PARAMETER_PATH_FORMAT = "/{app}/{env}/zero-etl/{integration_name}"


class ZeroETLIntegrationError(Exception):
    """Custom exception for Zero-ETL integration errors"""
    pass


def get_aws_clients():
    """
    Create and return AWS service clients with proper error handling.
    
    Returns:
        tuple: (glue_client, ssm_client)
    """
    try:
        glue_client = boto3.client('glue')
        ssm_client = boto3.client('ssm')
        return glue_client, ssm_client
    except Exception as e:
        logger.error(f"Failed to initialize AWS clients: {str(e)}")
        raise ZeroETLIntegrationError(f"AWS client initialization failed: {str(e)}")


def validate_event(event: Dict[str, Any]) -> None:
    """
    Validate that all required parameters are present in the event.
    
    Args:
        event: Lambda event dictionary
        
    Raises:
        ZeroETLIntegrationError: If required parameters are missing
    """
    required_fields = [
        'app', 'env', 'integrationName', 'tf'
    ]
    
    # Check common required fields
    for field in required_fields:
        if field not in event:
            raise ZeroETLIntegrationError(f"Missing required parameter: {field}")
    
    # Check action-specific required fields
    action = event.get('tf', {}).get('action')
    if action == 'create':
        create_fields = [
            'sourceArn', 'targetArn', 'targetTableName', 
            'targetRoleArn', 'IntegrationkmsKeyArn', 'TargetkmsKeyArn'
        ]
        for field in create_fields:
            if field not in event:
                raise ZeroETLIntegrationError(f"Missing required parameter for create action: {field}")


def create_integration(glue_client, ssm_client, event: Dict[str, Any]) -> Dict[str, Any]:
    """
    Create a Zero-ETL integration.
    
    Args:
        glue_client: Boto3 Glue client
        ssm_client: Boto3 SSM client
        event: Lambda event dictionary
        
    Returns:
        dict: Response with status code and message
    """
    try:
        app = event['app']
        env = event['env']
        source_arn = event['sourceArn']
        integration_name = event['integrationName']
        target_arn = event['targetArn']
        target_table_name = event['targetTableName']
        target_role_arn = event['targetRoleArn']
        integration_kms_key_arn = event['IntegrationkmsKeyArn']
        target_kms_key_arn = event['TargetkmsKeyArn']
        
        logger.info(f"Creating integration resource property for target: {target_arn}")
        integration_resource_property_result = glue_client.create_integration_resource_property(
            ResourceArn=target_arn,
            TargetProcessingProperties={
                'RoleArn': target_role_arn,
                'KmsArn': target_kms_key_arn
            }
        )
        
        logger.info(f"Creating integration: {integration_name}")
        integration_result = glue_client.create_integration(
            IntegrationName=integration_name,
            SourceArn=source_arn,
            TargetArn=target_arn,
            KmsKeyId=integration_kms_key_arn
        )
        
        logger.info(f"Creating integration table properties for table: {target_table_name}")
        glue_client.create_integration_table_properties(
            ResourceArn=integration_result['IntegrationArn'],
            TableName=target_table_name,
            TargetTableConfig={
                'TargetTableName': target_table_name
            }
        )
        
        # Store integration details in SSM Parameter Store
        parameter_name = SSM_PARAMETER_PATH_FORMAT.format(
            app=app, env=env, integration_name=integration_name
        )
        parameter_value = {
            'integrationArn': integration_result['IntegrationArn'],
            'resourcePropertyArn': integration_resource_property_result['ResourceArn'],
            'target': target_arn,
            'targetTable': target_table_name
        }
        
        logger.info(f"Storing integration details in SSM parameter: {parameter_name}")
        ssm_client.put_parameter(
            Name=parameter_name,
            Value=json.dumps(parameter_value),
            Type='String',
            Overwrite=True
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Zero-ETL integration created successfully',
                'integrationArn': integration_result['IntegrationArn']
            })
        }
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        error_message = e.response.get('Error', {}).get('Message', str(e))
        logger.error(f"AWS service error during create operation: {error_code} - {error_message}")
        
        if error_code == 'ResourceInUseException':
            logger.warning(f"Integration {integration_name} already exists")
            return {
                'statusCode': 409,
                'body': json.dumps({
                    'message': f"Integration {integration_name} already exists",
                    'error': error_message
                })
            }
        
        raise ZeroETLIntegrationError(f"Failed to create integration: {error_message}")
    except Exception as e:
        logger.error(f"Unexpected error during create operation: {str(e)}")
        raise ZeroETLIntegrationError(f"Failed to create integration: {str(e)}")


def delete_integration(glue_client, ssm_client, event: Dict[str, Any]) -> Dict[str, Any]:
    """
    Delete a Zero-ETL integration.
    
    Args:
        glue_client: Boto3 Glue client
        ssm_client: Boto3 SSM client
        event: Lambda event dictionary
        
    Returns:
        dict: Response with status code and message
    """
    try:
        app = event['app']
        env = event['env']
        integration_name = event['integrationName']
        
        parameter_name = SSM_PARAMETER_PATH_FORMAT.format(
            app=app, env=env, integration_name=integration_name
        )
        
        try:
            logger.info(f"Retrieving integration details from SSM parameter: {parameter_name}")
            result = ssm_client.get_parameter(Name=parameter_name)
            integration_details = json.loads(result['Parameter']['Value'])
            integration_arn = integration_details['integrationArn']
        except ClientError as e:
            if e.response.get('Error', {}).get('Code') == 'ParameterNotFound':
                logger.warning(f"Integration parameter not found: {parameter_name}")
                return {
                    'statusCode': 404,
                    'body': json.dumps({
                        'message': f"Integration {integration_name} not found"
                    })
                }
            raise
        
        logger.info(f"Deleting integration: {integration_arn}")
        glue_client.delete_integration(IntegrationIdentifier=integration_arn)
        
        logger.info(f"Deleting SSM parameter: {parameter_name}")
        ssm_client.delete_parameter(Name=parameter_name)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Zero-ETL integration deleted successfully'
            })
        }
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        error_message = e.response.get('Error', {}).get('Message', str(e))
        logger.error(f"AWS service error during delete operation: {error_code} - {error_message}")
        
        if error_code == 'EntityNotFoundException':
            logger.warning(f"Integration {integration_name} not found")
            # Clean up the parameter even if the integration is not found
            try:
                parameter_name = SSM_PARAMETER_PATH_FORMAT.format(
                    app=app, env=env, integration_name=integration_name
                )
                ssm_client.delete_parameter(Name=parameter_name)
            except Exception:
                pass
                
            return {
                'statusCode': 404,
                'body': json.dumps({
                    'message': f"Integration {integration_name} not found"
                })
            }
        
        raise ZeroETLIntegrationError(f"Failed to delete integration: {error_message}")
    except Exception as e:
        logger.error(f"Unexpected error during delete operation: {str(e)}")
        raise ZeroETLIntegrationError(f"Failed to delete integration: {str(e)}")


def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Main Lambda handler function.
    
    Args:
        event: Lambda event dictionary
        context: Lambda context object
        
    Returns:
        dict: Response with status code and message
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        # Validate event
        validate_event(event)
        
        # Get AWS clients
        glue_client, ssm_client = get_aws_clients()
        
        # Process based on action
        action = event['tf']['action']
        
        if action == 'create':
            return create_integration(glue_client, ssm_client, event)
        elif action == 'delete':
            return delete_integration(glue_client, ssm_client, event)
        else:
            logger.error(f"Unsupported action: {action}")
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'message': f"Unsupported action: {action}"
                })
            }
    except ZeroETLIntegrationError as e:
        logger.error(f"Zero-ETL integration error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Failed to process Zero-ETL integration',
                'error': str(e)
            })
        }
    except Exception as e:
        logger.error(f"Unhandled exception: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Internal server error',
                'error': str(e)
            })
        }
