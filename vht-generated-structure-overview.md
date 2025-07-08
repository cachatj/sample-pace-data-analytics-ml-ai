# VHT Projects - Generated Structure Overview

## What Gets Generated from Your JSON

### 1. vht-payer-propensity-producer
```
iac/roots/
├── sagemaker/vht-payer-propensity-producer/
│   ├── main.tf              # Uses ML profile (Profile 1)
│   ├── variables.tf         # Includes ENVIRONMENT_CONFIGS with ML pipeline blueprint
│   ├── outputs.tf          
│   ├── provider.tf         
│   ├── terraform.tfvars     # SOURCE_BUCKET = "vht-claims-data-daily-feed"
│   └── backend.hcl         
└── datazone/dz-vht-payer-propensity-producer/
    └── (standard DataZone files)

Makefile targets added:
- deploy-vht-payer-propensity-producer
- extract-vht-payer-propensity-producer-info
- destroy-vht-payer-propensity-producer
- deploy-vht-payer-propensity-producer-datazone
- destroy-vht-payer-propensity-producer-datazone
```

### 2. vht-claims-denial-producer
```
iac/roots/
├── sagemaker/vht-claims-denial-producer/
│   ├── main.tf              # Uses Bedrock profile (Profile 2)
│   ├── variables.tf         # Includes ENVIRONMENT_CONFIGS with Bedrock blueprints
│   ├── outputs.tf          
│   ├── provider.tf         
│   ├── terraform.tfvars     # SOURCE_BUCKET = "vht-claims-data-daily-feed"
│   └── backend.hcl         
└── datazone/dz-vht-claims-denial-producer/
    └── (standard DataZone files)

Makefile targets: (same pattern as above)
```

### 3. vht-rag-chat-producer (WITH DATALAKE!)
```
iac/roots/
├── sagemaker/vht-rag-chat-producer/
│   ├── main.tf              # Uses Bedrock profile (Profile 2)
│   ├── variables.tf         # Includes ENVIRONMENT_CONFIGS with RAG blueprints
│   ├── outputs.tf          
│   ├── provider.tf         
│   ├── terraform.tfvars     # SOURCE_BUCKET = "vht-documentation-data"
│   └── backend.hcl         
├── datazone/dz-vht-rag-chat-producer/
│   └── (standard DataZone files)
└── datalakes/vht_rag_chat_producer/    # ADDITIONAL DATALAKE!
    ├── main.tf              # Creates S3 buckets, Glue DB, S3 Tables
    ├── variables.tf         # TABLE_SCHEMAS includes chat_interactions
    ├── outputs.tf          
    ├── provider.tf         
    ├── terraform.tfvars    
    └── backend.hcl         

Makefile targets added:
- (all standard targets PLUS)
- deploy-vht-rag-chat-producer-datalake
- destroy-vht-rag-chat-producer-datalake
```

### 4. vht-analytics-consumer
```
iac/roots/
├── sagemaker/vht-analytics-consumer/
│   ├── main.tf              # Uses Analytics profile (Profile 3 for consumer)
│   ├── variables.tf         # Includes cross-account role in ENVIRONMENT_CONFIGS
│   ├── outputs.tf          
│   ├── provider.tf         
│   ├── terraform.tfvars     # SOURCE_BUCKET = "vht-ds-analytic-data"
│   └── backend.hcl         
└── datazone/dz-vht-analytics-consumer/
    └── (standard DataZone files)

Makefile targets: (same pattern as first two)
```

## Key Configuration Values Used

### From environment_configs:
- **Blueprint types** determine which SageMaker profile to use
- **Parameters** are stored and passed to the template module
- **Deployment order** is preserved in the configuration

### From table_schemas:
- Stored as Terraform variables
- For datalake projects, used to define Glue table structures
- Column definitions preserved for downstream use

### From source_bucket:
- Set in terraform.tfvars
- Available as a variable for the module to use
- Different bucket for each project type

## Profile Selection Logic

The generator analyzes blueprints to select profiles:

| Blueprint | Selected Profile | Purpose |
|-----------|-----------------|---------|
| sagemaker-ml-pipeline | Profile 1 | ML training & pipelines |
| bedrock-agents, bedrock-rag | Profile 2 | GenAI & Bedrock |
| lakehouse-connection, lakehouse-database | Profile 3 | Analytics & queries |
| api-gateway-lambda | Profile 3 (consumer) | API access |

## DataLake Creation

Only `vht-rag-chat-producer` creates a datalake because it has:
```json
"create_datalake": true
```

The datalake includes:
- Raw and processed S3 buckets
- Glue database: `vhtds_dev_vht_rag_chat_producer_lakehouse`
- S3 Tables bucket for Iceberg: `vhtds-dev-vht-rag-chat-producer-iceberg`
- Bucket policies for Glue and Athena access

## Environment Configs in Action

The ENVIRONMENT_CONFIGS variable contains the full blueprint configuration:

```hcl
ENVIRONMENT_CONFIGS = [
  {
    name = "ML Pipeline Environment"
    description = "SageMaker training, feature store, and inference endpoints"
    blueprint = "sagemaker-ml-pipeline"
    parameters = {
      source_database = "vht_claims_lakehouse"
      source_tables = ["claims_837_iceberg", "payments_835_iceberg"]
      # ... etc
    }
  }
]
```

This allows the SageMaker template module to configure the appropriate resources based on the blueprint type.
