# VHT Deployment of DAIVI solution

## AWS Details

AWS_ACCOUNT_ID: 263704881331
APP_NAME: vhtds
ENV_NAME: dev
AWS_PRIMARY_REGION: us-east-1
AWS_SECONDARY_REGION: us-east-2

ADMIN_ROLE: aws-vht-admin

## Generating Custom Projects within SageMaker domain.

#### VHT Projects 

```
VHT-DS Account (2637-0488-1331)
├── VHT-DataSci-Domain (SageMaker Unified Studio)
│   ├── VHT-Payer-Propensity-Producer
│   ├── VHT-Claims-Denial-Producer  
│   ├── VHT-Chatbot-Producer
│   └── VHT-Analytics-Consumer
└── Exchange Domain (DataZone)
    ├── Healthcare Data Catalog
    ├── Cross-Account Data Sharing
    └── Governance & Compliance
```

## Destroy the DAIVI Solution, all AWS Resources, services and config

Complete Destruction Process
Use the orchestrated destroy-all target:

`make destroy-all`
This target executes destruction in the correct dependency order: Makefile:1493

Manual Step-by-Step Destruction
If you prefer manual control, execute these targets in order:

Data Platform Components:
`make destroy-datazone` - Removes DataZone domains and projects Makefile:1505
`make destroy-project-configuration` - Removes SageMaker project configurations Makefile:1504
Data Lakes:
`make destroy-splunk-modules` - Removes Splunk data lake Makefile:1503
`make destroy-zetl-ddb` - Removes DynamoDB Zero ETL components Makefile:1502
`make destroy-inventory-modules` - Removes inventory data lake Makefile:1501
`make destroy-billing-modules` - Removes billing data lake Makefile:1499-1500
Core Platform:
`make destroy-athena` - Removes Athena resources Makefile:1498
`make destroy-projects` - Removes SageMaker producer/consumer projects Makefile:1497
`make destroy-domain` - Removes SageMaker domain Makefile:1496
Foundation:
`make destroy-idc` - Removes Identity Center configurations Makefile:1495
`make destroy-foundation `- Removes foundational resources (S3 buckets, IAM roles, KMS keys) Makefile:1494

Terraform Backend Cleanup
Finally, remove the Terraform backend infrastructure:

`make destroy-tf-backend-cf-stack`