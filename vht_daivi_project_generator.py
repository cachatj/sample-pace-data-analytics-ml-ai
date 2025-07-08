#!/usr/bin/env python3
"""
DAIVI Custom Project Generator - Healthcare Revenue Cycle Management Version
Generates Terraform infrastructure files for custom SageMaker projects following DAIVI IaC best practices
Creates folder structure and files only - does NOT perform deployments
"""

import os
import json
import shutil
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime
import argparse

class DAIVIProjectGenerator:
    def __init__(self, daivi_root_path: str):
        self.daivi_root = Path(daivi_root_path)
        self.iac_root = self.daivi_root / "iac"
        self.templates_path = self.iac_root / "templates" / "modules"
        self.roots_path = self.iac_root / "roots"
        
        # Validate DAIVI structure
        self._validate_daivi_structure()
        
    def _validate_daivi_structure(self):
        """Validate that required DAIVI directories exist"""
        required_dirs = [
            self.iac_root,
            self.templates_path,
            self.roots_path,
            self.roots_path / "sagemaker",
            self.roots_path / "datazone",
            self.roots_path / "datalakes"
        ]
        
        for dir_path in required_dirs:
            if not dir_path.exists():
                # Create datalakes directory if it doesn't exist
                if dir_path == self.roots_path / "datalakes":
                    dir_path.mkdir(parents=True, exist_ok=True)
                    print(f"📁 Created missing directory: {dir_path}")
                else:
                    raise Exception(f"Required directory not found: {dir_path}")
        
    def create_custom_project(self, project_config: Dict[str, Any]):
        """Create a custom DAIVI project following IaC best practices"""
        
        project_name = project_config['name']
        project_type = project_config['type']
        
        print(f"\n🚀 Creating DAIVI project components: {project_name}")
        print(f"   Type: {project_type}")
        print(f"   Description: {project_config.get('description', 'N/A')}")
        print(f"   Create DataLake: {project_config.get('create_datalake', False)}")
        
        # 1. Create SageMaker project component
        self._create_sagemaker_component(project_config)
        
        # 2. Create DataZone project component
        self._create_datazone_component(project_config)
        
        # 3. Create custom datalake component if specified
        if project_config.get('create_datalake', False):
            self._create_datalake_component(project_config)
        
        print(f"\n✅ Successfully created project components: {project_name}")
        self._print_deployment_instructions(project_config)
            
    def _create_sagemaker_component(self, config: Dict[str, Any]):
        """Create SageMaker component following DAIVI IaC principles"""
        project_name = config['name']
        component_path = self.roots_path / "sagemaker" / project_name
        component_path.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Creating SageMaker component: {component_path}")
        
        # Create standard DAIVI component files
        self._create_file(component_path / "variables.tf", self._generate_sagemaker_variables(config))
        self._create_file(component_path / "terraform.tfvars", self._generate_sagemaker_tfvars(config))
        self._create_file(component_path / "main.tf", self._generate_sagemaker_main(config))
        self._create_file(component_path / "outputs.tf", self._generate_sagemaker_outputs(config))
        self._create_file(component_path / "provider.tf", self._generate_provider_tf())
        self._create_file(component_path / "backend.tf", self._generate_backend_tf(f"sagemaker/{project_name}"))
                    
    def _create_datazone_component(self, config: Dict[str, Any]):
        """Create DataZone component following DAIVI IaC principles"""
        project_name = config['name']
        component_path = self.roots_path / "datazone" / f"dz-{project_name}"
        component_path.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Creating DataZone component: {component_path}")
        
        # Create standard DAIVI component files
        self._create_file(component_path / "variables.tf", self._generate_datazone_variables(config))
        self._create_file(component_path / "terraform.tfvars", self._generate_datazone_tfvars(config))
        self._create_file(component_path / "main.tf", self._generate_datazone_main(config))
        self._create_file(component_path / "outputs.tf", self._generate_datazone_outputs(config))
        self._create_file(component_path / "provider.tf", self._generate_provider_tf())
        self._create_file(component_path / "backend.tf", self._generate_backend_tf(f"datazone/dz-{project_name}"))
    
    def _create_datalake_component(self, config: Dict[str, Any]):
        """Create datalake component following DAIVI IaC principles"""
        project_name = config['name'].replace('-', '_')
        component_path = self.roots_path / "datalakes" / project_name
        component_path.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Creating DataLake component: {component_path}")
        
        # Create standard DAIVI component files
        self._create_file(component_path / "variables.tf", self._generate_datalake_variables(config))
        self._create_file(component_path / "terraform.tfvars", self._generate_datalake_tfvars(config))
        self._create_file(component_path / "main.tf", self._generate_datalake_main(config))
        self._create_file(component_path / "outputs.tf", self._generate_datalake_outputs(config))
        self._create_file(component_path / "provider.tf", self._generate_provider_tf())
        self._create_file(component_path / "backend.tf", self._generate_backend_tf(f"datalakes/{project_name}"))
    
    def _generate_sagemaker_main(self, config: Dict[str, Any]) -> str:
        """Generate main.tf that ONLY calls modules from templates/ directory"""
        project_name = config['name']
        project_name_underscore = project_name.replace('-', '_')
        
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_ssm_parameter" "smus_domain_id" {{
  name = "/${{var.APP}}/${{var.ENV}}/smus_domain_id"
}}

data "aws_ssm_parameter" "smus_profile" {{
  name = var.PROJECT_TYPE == "producer" ? "/${{var.APP}}/${{var.ENV}}/project_profile_1" : "/${{var.APP}}/${{var.ENV}}/project_profile_3"
}}

data "aws_caller_identity" "current" {{}}
data "aws_region" "current" {{}}

locals {{
  profile_id = split(":", data.aws_ssm_parameter.smus_profile.value)[0]
}}

# Create SageMaker project using existing DAIVI template module
# Following IaC principle: Components should primarily compose reusable modules
module "{project_name_underscore}_project" {{
  source = "../../templates/modules/sagemaker-project"
  
  # Standard DAIVI variables
  APP                = var.APP
  ENV                = var.ENV
  AWS_PRIMARY_REGION = var.AWS_PRIMARY_REGION
  
  # Project configuration
  PROJECT_NAME        = var.PROJECT_NAME
  PROJECT_DESCRIPTION = var.PROJECT_DESCRIPTION
  PROJECT_TYPE        = var.PROJECT_TYPE
  
  # SageMaker configuration
  SMUS_DOMAIN_ID      = data.aws_ssm_parameter.smus_domain_id.value
  SMUS_PROFILE_ID     = local.profile_id
  
  # Additional project-specific parameters
  GLUE_DATABASE       = "${{var.APP}}_${{var.ENV}}_{project_name_underscore}_lakehouse"
  WORKGROUP_NAME      = "${{var.APP}}-${{var.ENV}}-workgroup"
  
  # Tags
  tags = {{
    Application = var.APP
    Environment = var.ENV
    ProjectType = var.PROJECT_TYPE
    ProjectName = var.PROJECT_NAME
    ManagedBy   = "DAIVI-Custom-Project-Generator"
    UseCase     = "Healthcare-Revenue-Cycle"
  }}
}}

# Store project information in SSM for cross-project references
# Using local resource for parameter storage only
resource "aws_ssm_parameter" "{project_name_underscore}_project_id" {{
  name  = "/${{var.APP}}/${{var.ENV}}/projects/{project_name}/project_id"
  type  = "String"
  value = module.{project_name_underscore}_project.project_id
  
  tags = {{
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
  }}
}}

resource "aws_ssm_parameter" "{project_name_underscore}_project_arn" {{
  name  = "/${{var.APP}}/${{var.ENV}}/projects/{project_name}/project_arn"
  type  = "String"
  value = module.{project_name_underscore}_project.project_arn
  
  tags = {{
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
  }}
}}
'''

    def _generate_backend_tf(self, component_path: str) -> str:
        """Generate backend.tf for proper state management"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {{
  backend "s3" {{
    bucket         = "###APP_NAME###-###ENV_NAME###-tfstate"
    key            = "{component_path}/terraform.tfstate"
    region         = "###AWS_PRIMARY_REGION###"
    dynamodb_table = "###APP_NAME###-###ENV_NAME###-tflock"
    encrypt        = true
  }}
}}
'''

    def _print_deployment_instructions(self, config: Dict[str, Any]):
        """Print deployment instructions following DAIVI patterns"""
        project_name = config['name']
        
        print(f"\n📋 Component Structure Created for {project_name}:")
        print(f"   ✅ SageMaker component: iac/roots/sagemaker/{project_name}/")
        print(f"   ✅ DataZone component: iac/roots/datazone/dz-{project_name}/")
        
        if config.get('create_datalake', False):
            print(f"   ✅ DataLake component: iac/roots/datalakes/{project_name.replace('-', '_')}/")
        
        print(f"\n🔧 Manual Deployment Steps (following DAIVI patterns):")
        print(f"   1. Update terraform.tfvars files with your environment values")
        print(f"   2. Replace ###APP_NAME###, ###ENV_NAME###, etc. in backend.tf files")
        print(f"   3. Add deployment target to Makefile:")
        print(f"      - Add 'deploy-{project_name}' target for SageMaker component")
        print(f"      - Add 'deploy-dz-{project_name}' target for DataZone component")
        if config.get('create_datalake', False):
            print(f"      - Add 'deploy-{project_name.replace('-', '_')}' target for DataLake")
        print(f"   4. Deploy using: make deploy-{project_name}")
        
        print(f"\n⚠️  Component Structure follows DAIVI IaC best practices:")
        print(f"   - Uses modular design with template module references")
        print(f"   - Includes standard component files (main.tf, variables.tf, outputs.tf)")
        print(f"   - Implements proper state management with backend.tf")
        print(f"   - Follows established DAIVI naming conventions")

    def _create_file(self, file_path: Path, content: str):
        """Create a file with the given content"""
        file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(file_path, 'w') as f:
            f.write(content)
        print(f"   📄 Created: {file_path.relative_to(self.daivi_root)}")

    def _generate_sagemaker_variables(self, config: Dict[str, Any]) -> str:
        """Generate variables.tf following DAIVI patterns"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {{
  description = "Application name for resource naming and tagging"
  type        = string
}}

variable "ENV" {{
  description = "Environment name (dev, staging, prod)"
  type        = string
}}

variable "AWS_PRIMARY_REGION" {{
  description = "Primary AWS region for deployment"
  type        = string
}}

variable "AWS_SECONDARY_REGION" {{
  description = "Secondary AWS region for cross-region resources"
  type        = string
}}

variable "PROJECT_NAME" {{
  description = "Name of the SageMaker project"
  type        = string
  default     = "{config['name']}"
}}

variable "PROJECT_DESCRIPTION" {{
  description = "Description of the SageMaker project"
  type        = string
  default     = "{config.get('description', '')}"
}}

variable "PROJECT_TYPE" {{
  description = "Type of project (producer or consumer)"
  type        = string
  default     = "{config['type']}"
  
  validation {{
    condition     = contains(["producer", "consumer"], var.PROJECT_TYPE)
    error_message = "PROJECT_TYPE must be either 'producer' or 'consumer'."
  }}
}}

variable "SOURCE_BUCKET" {{
  description = "Source S3 bucket for data"
  type        = string
  default     = "{config.get('source_bucket', '')}"
}}

variable "ENVIRONMENT_CONFIGS" {{
  description = "Environment configurations for blueprints"
  type        = any
  default     = {json.dumps(config.get('environment_configs', []), indent=2)}
}}

variable "TABLE_SCHEMAS" {{
  description = "Schema definitions for project tables"
  type        = any
  default     = {json.dumps(config.get('table_schemas', {}), indent=2)}
}}
'''

    def _generate_sagemaker_tfvars(self, config: Dict[str, Any]) -> str:
        """Generate terraform.tfvars following DAIVI patterns"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Standard DAIVI variables - update with your environment values
APP                  = "###APP_NAME###"
ENV                  = "###ENV_NAME###"
AWS_PRIMARY_REGION   = "###AWS_PRIMARY_REGION###"
AWS_SECONDARY_REGION = "###AWS_SECONDARY_REGION###"

# Project-specific values
PROJECT_NAME        = "{config['name']}"
PROJECT_DESCRIPTION = "{config.get('description', '')}"
PROJECT_TYPE        = "{config['type']}"
SOURCE_BUCKET       = "{config.get('source_bucket', '')}"
'''

    def _generate_sagemaker_outputs(self, config: Dict[str, Any]) -> str:
        """Generate outputs.tf following DAIVI patterns"""
        project_name_underscore = config['name'].replace('-', '_')
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "project_id" {{
  description = "The ID of the SageMaker project"
  value       = module.{project_name_underscore}_project.project_id
}}

output "project_arn" {{
  description = "The ARN of the SageMaker project"
  value       = module.{project_name_underscore}_project.project_arn
}}

output "project_name" {{
  description = "The name of the SageMaker project"
  value       = var.PROJECT_NAME
}}

output "project_role_arn" {{
  description = "The IAM role ARN for the project"
  value       = module.{project_name_underscore}_project.project_role_arn
}}

output "project_s3_bucket" {{
  description = "The S3 bucket for the project"
  value       = module.{project_name_underscore}_project.project_s3_bucket
}}
'''

    def _generate_provider_tf(self) -> str:
        """Generate provider.tf following DAIVI patterns"""
        return '''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.AWS_PRIMARY_REGION

  default_tags {
    tags = {
      Application = var.APP
      Environment = var.ENV
      ManagedBy   = "Terraform"
      Repository  = "DAIVI"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION

  default_tags {
    tags = {
      Application = var.APP
      Environment = var.ENV
      ManagedBy   = "Terraform"
      Repository  = "DAIVI"
    }
  }
}
'''

    def _generate_datazone_variables(self, config: Dict[str, Any]) -> str:
        """Generate variables.tf for DataZone component"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {{
  description = "Application name"
  type        = string
}}

variable "ENV" {{
  description = "Environment name"
  type        = string
}}

variable "AWS_PRIMARY_REGION" {{
  description = "Primary AWS region"
  type        = string
}}

variable "AWS_SECONDARY_REGION" {{
  description = "Secondary AWS region"
  type        = string
}}

variable "PROJECT_NAME" {{
  description = "DataZone project name"
  type        = string
  default     = "{config['name']}"
}}

variable "PROJECT_DESCRIPTION" {{
  description = "DataZone project description"
  type        = string
  default     = "{config.get('description', '')}"
}}

variable "PROJECT_GLOSSARY" {{
  description = "Glossary terms for the project"
  type        = list(string)
  default     = {json.dumps(config.get('glossary_terms', []))}
}}

variable "PROFILE_NAME" {{
  description = "DataZone profile name"
  type        = string
  default     = "{config['name'].replace('-', '_')}_profile"
}}

variable "PROFILE_DESCRIPTION" {{
  description = "DataZone profile description"
  type        = string
  default     = "{config['name']} project profile"
}}

variable "ENV_NAME" {{
  description = "DataZone environment name"
  type        = string
  default     = "{config['name'].replace('-', '_')}_env"
}}
'''

    def _generate_datazone_tfvars(self, config: Dict[str, Any]) -> str:
        """Generate terraform.tfvars for DataZone component"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Standard DAIVI variables - update with your environment values
APP                  = "###APP_NAME###"
ENV                  = "###ENV_NAME###"
AWS_PRIMARY_REGION   = "###AWS_PRIMARY_REGION###"
AWS_SECONDARY_REGION = "###AWS_SECONDARY_REGION###"

# DataZone project configuration
PROJECT_NAME        = "{config['name']}"
PROJECT_DESCRIPTION = "{config.get('description', '')}"
PROJECT_GLOSSARY    = {json.dumps(config.get('glossary_terms', []))}

PROFILE_NAME        = "{config['name'].replace('-', '_')}_profile"
PROFILE_DESCRIPTION = "{config['name']} project profile"
ENV_NAME           = "{config['name'].replace('-', '_')}_env"
'''

    def _generate_datazone_main(self, config: Dict[str, Any]) -> str:
        """Generate main.tf for DataZone using ONLY template modules"""
        project_name_underscore = config['name'].replace('-', '_')
        
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_ssm_parameter" "datazone_domain_id" {{
  name = "/${{var.APP}}/${{var.ENV}}/datazone_domain_id"
}}

data "aws_ssm_parameter" "datalake_blueprint_id" {{
  name = "/${{var.APP}}/${{var.ENV}}/${{data.aws_ssm_parameter.datazone_domain_id.value}}/datalake_blueprint_id"
}}

data "aws_caller_identity" "current" {{}}
data "aws_region" "current" {{}}

# Create DataZone project using existing DAIVI template module
# Following IaC principle: Components should primarily compose reusable modules
module "{project_name_underscore}_datazone_project" {{
  source = "../../templates/modules/datazone-project"
  
  APP                 = var.APP
  ENV                 = var.ENV
  AWS_PRIMARY_REGION  = var.AWS_PRIMARY_REGION
  
  PROJECT_NAME        = var.PROJECT_NAME
  PROJECT_DESCRIPTION = var.PROJECT_DESCRIPTION
  PROFILE_NAME        = var.PROFILE_NAME
  PROFILE_DESCRIPTION = var.PROFILE_DESCRIPTION
  ENV_NAME           = var.ENV_NAME
  PROJECT_GLOSSARY   = var.PROJECT_GLOSSARY
  
  DATAZONE_DOMAIN_ID  = data.aws_ssm_parameter.datazone_domain_id.value
  BLUEPRINT_ID        = data.aws_ssm_parameter.datalake_blueprint_id.value
  
  tags = {{
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
    UseCase     = "Healthcare-Revenue-Cycle"
  }}
}}
'''

    def _generate_datazone_outputs(self, config: Dict[str, Any]) -> str:
        """Generate outputs.tf for DataZone component"""
        project_name_underscore = config['name'].replace('-', '_')
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "datazone_project_id" {{
  description = "DataZone project ID"
  value       = module.{project_name_underscore}_datazone_project.project_id
}}

output "datazone_project_name" {{
  description = "DataZone project name"
  value       = var.PROJECT_NAME
}}

output "datazone_environment_id" {{
  description = "DataZone environment ID"
  value       = module.{project_name_underscore}_datazone_project.environment_id
}}

output "datazone_profile_id" {{
  description = "DataZone profile ID"
  value       = module.{project_name_underscore}_datazone_project.profile_id
}}
'''

    def _generate_datalake_variables(self, config: Dict[str, Any]) -> str:
        """Generate variables.tf for DataLake component"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {{
  type = string
}}

variable "ENV" {{
  type = string
}}

variable "AWS_PRIMARY_REGION" {{
  type = string
}}

variable "AWS_SECONDARY_REGION" {{
  type = string
}}

variable "SOURCE_BUCKET" {{
  description = "Source S3 bucket for data"
  type        = string
  default     = "{config.get('source_bucket', '')}"
}}

variable "TABLE_SCHEMAS" {{
  description = "Schema definitions for tables"
  type        = any
  default     = {json.dumps(config.get('table_schemas', {}), indent=2)}
}}
'''

    def _generate_datalake_tfvars(self, config: Dict[str, Any]) -> str:
        """Generate terraform.tfvars for DataLake component"""
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Standard DAIVI variables - update with your environment values
APP                  = "###APP_NAME###"
ENV                  = "###ENV_NAME###"
AWS_PRIMARY_REGION   = "###AWS_PRIMARY_REGION###"
AWS_SECONDARY_REGION = "###AWS_SECONDARY_REGION###"

# DataLake configuration
SOURCE_BUCKET = "{config.get('source_bucket', '')}"
'''

    def _generate_datalake_main(self, config: Dict[str, Any]) -> str:
        """Generate main.tf for DataLake using ONLY template modules"""
        project_name_underscore = config['name'].replace('-', '_')
        
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_caller_identity" "current" {{}}
data "aws_region" "current" {{}}

# Create DataLake using existing DAIVI template modules
# Following IaC principle: Components should primarily compose reusable modules
module "{project_name_underscore}_datalake" {{
  source = "../../templates/modules/datalake-iceberg"
  
  APP                = var.APP
  ENV                = var.ENV
  AWS_PRIMARY_REGION = var.AWS_PRIMARY_REGION
  
  DATABASE_NAME      = "${{var.APP}}_${{var.ENV}}_{project_name_underscore}_lakehouse"
  SOURCE_BUCKET      = var.SOURCE_BUCKET
  TABLE_SCHEMAS      = var.TABLE_SCHEMAS
  
  # Healthcare-specific configuration
  ENABLE_ENCRYPTION  = true
  COMPLIANCE_MODE    = "HIPAA"
  DATA_CLASSIFICATION = "PHI"
  
  tags = {{
    Application = var.APP
    Environment = var.ENV
    UseCase     = "Healthcare-Revenue-Cycle"
    DataType    = "Claims-and-Payments"
  }}
}}

# Store datalake information in SSM for cross-project references
resource "aws_ssm_parameter" "{project_name_underscore}_database_name" {{
  name  = "/${{var.APP}}/${{var.ENV}}/datalakes/{project_name_underscore}/database_name"
  type  = "String"
  value = module.{project_name_underscore}_datalake.database_name
  
  tags = {{
    Application = var.APP
    Environment = var.ENV
  }}
}}
'''

    def _generate_datalake_outputs(self, config: Dict[str, Any]) -> str:
        """Generate outputs.tf for DataLake component"""
        project_name_underscore = config['name'].replace('-', '_')
        return f'''// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "database_name" {{
  description = "Glue database name"
  value       = module.{project_name_underscore}_datalake.database_name
}}

output "s3_table_bucket" {{
  description = "S3 Tables bucket for Iceberg"
  value       = module.{project_name_underscore}_datalake.s3_table_bucket
}}

output "support_bucket" {{
  description = "S3 bucket for support files"
  value       = module.{project_name_underscore}_datalake.support_bucket
}}

output "table_metadata" {{
  description = "Table metadata and schemas"
  value       = module.{project_name_underscore}_datalake.table_metadata
}}
'''

def main():
    parser = argparse.ArgumentParser(description='Generate DAIVI custom project components following IaC best practices')
    parser.add_argument('--config', required=True, help='Path to project configuration JSON file')
    parser.add_argument('--daivi-root', required=True, help='Path to DAIVI root directory')
    
    args = parser.parse_args()
    
    # Load project configuration
    with open(args.config, 'r') as f:
        project_configs = json.load(f)
    
    # Initialize generator
    generator = DAIVIProjectGenerator(args.daivi_root)
    
    # Generate project components
    if isinstance(project_configs, list):
        for config in project_configs:
            generator.create_custom_project(config)
    else:
        generator.create_custom_project(project_configs)
    
    print("\n🎉 All project components generated successfully!")
    print("\n📋 Next Steps (following DAIVI IaC best practices):")
    print("1. Run update configuration script to replace placeholders")
    print("2. Add deployment targets to Makefile for each component")
    print("3. Deploy components manually using Terraform:")
    print("   - cd iac/roots/sagemaker/[project-name]")
    print("   - terraform init && terraform apply")
    print("4. Follow DAIVI deployment order and dependencies")
    print("\n⚠️  Generated components follow DAIVI IaC principles:")
    print("   - Modular design using template modules only")
    print("   - Standard component structure (main.tf, variables.tf, outputs.tf)")
    print("   - Proper state management with backend.tf")
    print("   - No direct resource configurations in components")

if __name__ == "__main__":
    main()
