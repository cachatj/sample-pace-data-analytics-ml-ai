# VHT Healthcare Revenue Cycle Management - DAIVI Component Generation & Deployment Guide

## Overview

This guide provides step-by-step instructions for generating and deploying custom healthcare revenue cycle management components using the DAIVI framework and AWS SageMaker Unified Studio. The **DAIVI Custom Project Generator** creates component folder structures and files following DAIVI IaC best practices - it does NOT perform deployments automatically.

## Prerequisites

1. **AWS Account Setup**
   - AWS CLI configured with appropriate credentials
   - Administrative access to deploy AWS resources
   - Account must support SageMaker Unified Studio and DataZone

2. **DAIVI Foundation Deployed**
   - DAIVI infrastructure already deployed (Foundation, IDC, Domain steps)
   - SageMaker Unified Studio domain configured
   - DataZone domain configured
   - Required IAM roles and template modules in place

3. **Development Environment**
   - Python 3.7+
   - Terraform >= 1.0
   - Bash shell (for scripts)

## Component Structure

The healthcare revenue cycle management solution generates 4 custom components following DAIVI IaC patterns:

1. **vht-payer-propensity-producer** - Payer propensity modeling with AutoGluon
2. **vht-claims-denial-mgmt-producer** - Claims denial management with Bedrock Agents
3. **vht-rag-chat-producer** - RAG applications and knowledge-based chat
4. **vht-analytics-consumer** - Cross-project analytics and API endpoints
5. **vht-claims-lakehouse** - Claims data lakehouse with 837/835 schemas

## Step-by-Step Process

### Step 1: Generate Component Infrastructure Files

Generate all the Terraform component files following DAIVI IaC best practices:

```bash
# Navigate to DAIVI root directory
cd /path/to/daivi

# Generate all 4 VHT project components
python3 vht_daivi_project_generator.py \
  --config custom_projects/configs/vht_projects_configs.json \
  --daivi-root .

# Generate the claims lakehouse component
python3 vht_daivi_project_generator.py \
  --config custom_projects/configs/vht-claims-lakehouse.json \
  --daivi-root .
```

**What this creates:**
- Component directories in `iac/roots/sagemaker/`, `iac/roots/datazone/`, `iac/roots/datalakes/`
- Standard DAIVI component files: `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`, `backend.tf`
- Terraform configurations that reference existing template modules only
- No direct resource configurations (following DAIVI modular design principle)

### Step 2: Update Component Configurations

Update all generated component configurations with your environment values:

```bash
# Make the script executable
chmod +x scripts/update_all_configs.sh

# Run interactively (recommended)
./scripts/update_all_configs.sh

# Or with parameters
./scripts/update_all_configs.sh vhtds dev us-east-1 us-east-2
```

**What this does:**
- Creates backup of original files
- Replaces all `###PLACEHOLDER###` values with your environment values
- Updates `backend.tf` files with correct S3 backend configuration
- Verifies all placeholders were replaced successfully

### Step 3: Add Makefile Deployment Targets

Following DAIVI patterns, add deployment targets to your Makefile:

```makefile
#################### VHT HEALTHCARE REVENUE CYCLE MANAGEMENT ####################

#################### VHT Claims Lakehouse (Deploy First) ####################

deploy-vht-claims-lakehouse:
	@echo "🚀 Deploying VHT Claims Lakehouse"
	(cd iac/roots/datalakes/vht_claims_lakehouse; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Claims Lakehouse"

destroy-vht-claims-lakehouse:
	@echo "🔥 Destroying VHT Claims Lakehouse"
	(cd iac/roots/datalakes/vht_claims_lakehouse; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Claims Lakehouse"

#################### VHT Payer Propensity Producer ####################

# SageMaker Project
deploy-vht-payer-propensity-producer:
	@echo "🚀 Deploying VHT Payer Propensity Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-payer-propensity-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Payer Propensity Producer (SageMaker)"

destroy-vht-payer-propensity-producer:
	@echo "🔥 Destroying VHT Payer Propensity Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-payer-propensity-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Payer Propensity Producer (SageMaker)"

# DataZone Project
deploy-dz-vht-payer-propensity-producer:
	@echo "🚀 Deploying VHT Payer Propensity Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-payer-propensity-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Payer Propensity Producer (DataZone)"

destroy-dz-vht-payer-propensity-producer:
	@echo "🔥 Destroying VHT Payer Propensity Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-payer-propensity-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Payer Propensity Producer (DataZone)"

# DataLake
deploy-vht-payer-propensity-producer-datalake:
	@echo "🚀 Deploying VHT Payer Propensity Producer (DataLake)"
	(cd iac/roots/datalakes/vht_payer_propensity_producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Payer Propensity Producer (DataLake)"

destroy-vht-payer-propensity-producer-datalake:
	@echo "🔥 Destroying VHT Payer Propensity Producer (DataLake)"
	(cd iac/roots/datalakes/vht_payer_propensity_producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Payer Propensity Producer (DataLake)"

# Extract Info
extract-vht-payer-propensity-producer-info:
	@echo "📋 Extracting VHT Payer Propensity Producer information"
	(cd iac/roots/sagemaker/vht-payer-propensity-producer; \
		terraform init; \
		terraform output -json > vht-payer-propensity-producer_outputs.json;)
	@echo "✅ Finished extracting VHT Payer Propensity Producer info"

#################### VHT Claims Denial Management Producer ####################

# SageMaker Project
deploy-vht-claims-denial-mgmt-producer:
	@echo "🚀 Deploying VHT Claims Denial Management Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-claims-denial-mgmt-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Claims Denial Management Producer (SageMaker)"

destroy-vht-claims-denial-mgmt-producer:
	@echo "🔥 Destroying VHT Claims Denial Management Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-claims-denial-mgmt-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Claims Denial Management Producer (SageMaker)"

# DataZone Project
deploy-dz-vht-claims-denial-mgmt-producer:
	@echo "🚀 Deploying VHT Claims Denial Management Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-claims-denial-mgmt-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Claims Denial Management Producer (DataZone)"

destroy-dz-vht-claims-denial-mgmt-producer:
	@echo "🔥 Destroying VHT Claims Denial Management Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-claims-denial-mgmt-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Claims Denial Management Producer (DataZone)"

# DataLake
deploy-vht-claims-denial-mgmt-producer-datalake:
	@echo "🚀 Deploying VHT Claims Denial Management Producer (DataLake)"
	(cd iac/roots/datalakes/vht_claims_denial_mgmt_producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Claims Denial Management Producer (DataLake)"

destroy-vht-claims-denial-mgmt-producer-datalake:
	@echo "🔥 Destroying VHT Claims Denial Management Producer (DataLake)"
	(cd iac/roots/datalakes/vht_claims_denial_mgmt_producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Claims Denial Management Producer (DataLake)"

# Extract Info
extract-vht-claims-denial-mgmt-producer-info:
	@echo "📋 Extracting VHT Claims Denial Management Producer information"
	(cd iac/roots/sagemaker/vht-claims-denial-mgmt-producer; \
		terraform init; \
		terraform output -json > vht-claims-denial-mgmt-producer_outputs.json;)
	@echo "✅ Finished extracting VHT Claims Denial Management Producer info"

#################### VHT RAG Chat Producer ####################

# SageMaker Project
deploy-vht-rag-chat-producer:
	@echo "🚀 Deploying VHT RAG Chat Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-rag-chat-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT RAG Chat Producer (SageMaker)"

destroy-vht-rag-chat-producer:
	@echo "🔥 Destroying VHT RAG Chat Producer (SageMaker)"
	(cd iac/roots/sagemaker/vht-rag-chat-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT RAG Chat Producer (SageMaker)"

# DataZone Project
deploy-dz-vht-rag-chat-producer:
	@echo "🚀 Deploying VHT RAG Chat Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-rag-chat-producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT RAG Chat Producer (DataZone)"

destroy-dz-vht-rag-chat-producer:
	@echo "🔥 Destroying VHT RAG Chat Producer (DataZone)"
	(cd iac/roots/datazone/dz-vht-rag-chat-producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT RAG Chat Producer (DataZone)"

# DataLake
deploy-vht-rag-chat-producer-datalake:
	@echo "🚀 Deploying VHT RAG Chat Producer (DataLake)"
	(cd iac/roots/datalakes/vht_rag_chat_producer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT RAG Chat Producer (DataLake)"

destroy-vht-rag-chat-producer-datalake:
	@echo "🔥 Destroying VHT RAG Chat Producer (DataLake)"
	(cd iac/roots/datalakes/vht_rag_chat_producer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT RAG Chat Producer (DataLake)"

# Extract Info
extract-vht-rag-chat-producer-info:
	@echo "📋 Extracting VHT RAG Chat Producer information"
	(cd iac/roots/sagemaker/vht-rag-chat-producer; \
		terraform init; \
		terraform output -json > vht-rag-chat-producer_outputs.json;)
	@echo "✅ Finished extracting VHT RAG Chat Producer info"

#################### VHT Analytics Consumer ####################

# SageMaker Project
deploy-vht-analytics-consumer:
	@echo "🚀 Deploying VHT Analytics Consumer (SageMaker)"
	(cd iac/roots/sagemaker/vht-analytics-consumer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Analytics Consumer (SageMaker)"

destroy-vht-analytics-consumer:
	@echo "🔥 Destroying VHT Analytics Consumer (SageMaker)"
	(cd iac/roots/sagemaker/vht-analytics-consumer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Analytics Consumer (SageMaker)"

# DataZone Project
deploy-dz-vht-analytics-consumer:
	@echo "🚀 Deploying VHT Analytics Consumer (DataZone)"
	(cd iac/roots/datazone/dz-vht-analytics-consumer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Analytics Consumer (DataZone)"

destroy-dz-vht-analytics-consumer:
	@echo "🔥 Destroying VHT Analytics Consumer (DataZone)"
	(cd iac/roots/datazone/dz-vht-analytics-consumer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Analytics Consumer (DataZone)"

# DataLake
deploy-vht-analytics-consumer-datalake:
	@echo "🚀 Deploying VHT Analytics Consumer (DataLake)"
	(cd iac/roots/datalakes/vht_analytics_consumer; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "✅ Finished deploying VHT Analytics Consumer (DataLake)"

destroy-vht-analytics-consumer-datalake:
	@echo "🔥 Destroying VHT Analytics Consumer (DataLake)"
	(cd iac/roots/datalakes/vht_analytics_consumer; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "✅ Finished destroying VHT Analytics Consumer (DataLake)"

# Extract Info
extract-vht-analytics-consumer-info:
	@echo "📋 Extracting VHT Analytics Consumer information"
	(cd iac/roots/sagemaker/vht-analytics-consumer; \
		terraform init; \
		terraform output -json > vht-analytics-consumer_outputs.json;)
	@echo "✅ Finished extracting VHT Analytics Consumer info"

#################### VHT Grouped Deployment Targets ####################

# Deploy all VHT SageMaker projects
deploy-vht-sagemaker-all: deploy-vht-payer-propensity-producer deploy-vht-claims-denial-mgmt-producer deploy-vht-rag-chat-producer deploy-vht-analytics-consumer

# Deploy all VHT DataZone projects
deploy-vht-datazone-all: deploy-dz-vht-payer-propensity-producer deploy-dz-vht-claims-denial-mgmt-producer deploy-dz-vht-rag-chat-producer deploy-dz-vht-analytics-consumer

# Deploy all VHT DataLake projects
deploy-vht-datalake-all: deploy-vht-claims-lakehouse deploy-vht-payer-propensity-producer-datalake deploy-vht-claims-denial-mgmt-producer-datalake deploy-vht-rag-chat-producer-datalake deploy-vht-analytics-consumer-datalake

# Deploy complete VHT solution (in correct order)
deploy-vht-all: deploy-vht-claims-lakehouse deploy-vht-sagemaker-all deploy-vht-datazone-all deploy-vht-datalake-all

# Extract all VHT project information
extract-vht-all-info: extract-vht-payer-propensity-producer-info extract-vht-claims-denial-mgmt-producer-info extract-vht-rag-chat-producer-info extract-vht-analytics-consumer-info

#################### VHT Grouped Destroy Targets ####################

# Destroy all VHT DataLake projects (destroy first to avoid dependencies)
destroy-vht-datalake-all: destroy-vht-payer-propensity-producer-datalake destroy-vht-claims-denial-mgmt-producer-datalake destroy-vht-rag-chat-producer-datalake destroy-vht-analytics-consumer-datalake destroy-vht-claims-lakehouse

# Destroy all VHT DataZone projects
destroy-vht-datazone-all: destroy-dz-vht-payer-propensity-producer destroy-dz-vht-claims-denial-mgmt-producer destroy-dz-vht-rag-chat-producer destroy-dz-vht-analytics-consumer

# Destroy all VHT SageMaker projects
destroy-vht-sagemaker-all: destroy-vht-payer-propensity-producer destroy-vht-claims-denial-mgmt-producer destroy-vht-rag-chat-producer destroy-vht-analytics-consumer

# Destroy complete VHT solution (in correct reverse order)
destroy-vht-all: destroy-vht-datalake-all destroy-vht-datazone-all destroy-vht-sagemaker-all

#################### VHT Individual Project Deployment (All Components) ####################

# Deploy complete Payer Propensity Producer (all components)
deploy-vht-payer-propensity-complete: deploy-vht-payer-propensity-producer deploy-dz-vht-payer-propensity-producer deploy-vht-payer-propensity-producer-datalake

# Deploy complete Claims Denial Management Producer (all components)
deploy-vht-claims-denial-complete: deploy-vht-claims-denial-mgmt-producer deploy-dz-vht-claims-denial-mgmt-producer deploy-vht-claims-denial-mgmt-producer-datalake

# Deploy complete RAG Chat Producer (all components)
deploy-vht-rag-chat-complete: deploy-vht-rag-chat-producer deploy-dz-vht-rag-chat-producer deploy-vht-rag-chat-producer-datalake

# Deploy complete Analytics Consumer (all components)
deploy-vht-analytics-complete: deploy-vht-analytics-consumer deploy-dz-vht-analytics-consumer deploy-vht-analytics-consumer-datalake

#################### VHT Individual Project Destroy (All Components) ####################

# Destroy complete Payer Propensity Producer (all components)
destroy-vht-payer-propensity-complete: destroy-vht-payer-propensity-producer-datalake destroy-dz-vht-payer-propensity-producer destroy-vht-payer-propensity-producer

# Destroy complete Claims Denial Management Producer (all components)
destroy-vht-claims-denial-complete: destroy-vht-claims-denial-mgmt-producer-datalake destroy-dz-vht-claims-denial-mgmt-producer destroy-vht-claims-denial-mgmt-producer

# Destroy complete RAG Chat Producer (all components)
destroy-vht-rag-chat-complete: destroy-vht-rag-chat-producer-datalake destroy-dz-vht-rag-chat-producer destroy-vht-rag-chat-producer

# Destroy complete Analytics Consumer (all components)
destroy-vht-analytics-complete: destroy-vht-analytics-consumer-datalake destroy-dz-vht-analytics-consumer destroy-vht-analytics-consumer

#################### VHT Validation and Status Targets ####################

# Validate all VHT Terraform configurations
validate-vht-all:
	@echo "🔍 Validating all VHT Terraform configurations"
	@for dir in $$(find iac/roots -type d -name "*vht*"); do \
		echo "Validating $$dir"; \
		cd $$dir && terraform validate && cd - > /dev/null || exit 1; \
	done
	@echo "✅ All VHT configurations validated successfully"

# Check status of all VHT deployments
status-vht-all:
	@echo "📊 Checking status of all VHT deployments"
	@for dir in $$(find iac/roots -type d -name "*vht*"); do \
		echo "Checking $$dir"; \
		cd $$dir && terraform show && cd - > /dev/null; \
	done

# Plan all VHT deployments (dry run)
plan-vht-all:
	@echo "📋 Planning all VHT deployments (dry run)"
	@for dir in $$(find iac/roots -type d -name "*vht*"); do \
		echo "Planning $$dir"; \
		cd $$dir && terraform init && terraform plan && cd - > /dev/null; \
	done

#################### VHT Utility Targets ####################

# Clean Terraform cache for all VHT projects
clean-vht-terraform:
	@echo "🧹 Cleaning Terraform cache for VHT projects"
	@find iac/roots -name ".terraform" -path "*/vht*" -exec rm -rf {} + 2>/dev/null || true
	@find iac/roots -name "terraform.tfstate.backup" -path "*/vht*" -delete 2>/dev/null || true
	@echo "✅ Cleaned Terraform cache for VHT projects"

# Format all VHT Terraform files
format-vht-terraform:
	@echo "🎨 Formatting all VHT Terraform files"
	@for dir in $$(find iac/roots -type d -name "*vht*"); do \
		echo "Formatting $$dir"; \
		cd $$dir && terraform fmt && cd - > /dev/null; \
	done
	@echo "✅ Formatted all VHT Terraform files"

# Show VHT deployment order
show-vht-deployment-order:
	@echo "📋 VHT Deployment Order:"
	@echo "1. make deploy-vht-claims-lakehouse                    # Deploy claims lakehouse first"
	@echo "2. make deploy-vht-payer-propensity-producer           # Deploy SageMaker projects"
	@echo "3. make deploy-vht-claims-denial-mgmt-producer"
	@echo "4. make deploy-vht-rag-chat-producer"
	@echo "5. make deploy-vht-analytics-consumer"
	@echo "6. make deploy-vht-datazone-all                        # Deploy DataZone projects"
	@echo "7. make deploy-vht-datalake-all                        # Deploy additional DataLakes"
	@echo ""
	@echo "Or use grouped targets:"
	@echo "make deploy-vht-all                                    # Deploy everything in order"
	@echo "make deploy-vht-payer-propensity-complete             # Deploy one complete project"
```

### Step 4: Verify DAIVI Foundation is Deployed

Ensure the DAIVI foundation components are already deployed:

```bash
# Verify foundation components exist
make deploy-foundation-all    # If not already deployed
make deploy-idc-all          # If not already deployed  
make deploy-domain-all       # If not already deployed
make deploy-projects-all     # If not already deployed
```

### Step 5: Deploy VHT Components

### **Recommended Deployment Order:**
```bash
# 1. Deploy claims lakehouse first (required by other projects)
make deploy-vht-claims-lakehouse

# 2. Deploy SageMaker projects
make deploy-vht-sagemaker-all

# 3. Deploy DataZone projects  
make deploy-vht-datazone-all

# 4. Deploy additional DataLakes
make deploy-vht-datalake-all

# OR deploy everything at once (follows correct order)
make deploy-vht-all
```

### **Individual Project Deployment:**
```bash
# Deploy complete individual projects (all 3 components)
make deploy-vht-payer-propensity-complete
make deploy-vht-claims-denial-complete
make deploy-vht-rag-chat-complete
make deploy-vht-analytics-complete
```

### **Component-Level Deployment:**
```bash
# Deploy specific components only
make deploy-vht-payer-propensity-producer              # SageMaker only
make deploy-dz-vht-payer-propensity-producer           # DataZone only
make deploy-vht-payer-propensity-producer-datalake     # DataLake only
```

## 🔧 **Utility Commands**

### **Validation & Status:**
```bash
make validate-vht-all          # Validate all Terraform configs
make plan-vht-all             # Dry run all deployments
make status-vht-all           # Check deployment status
make show-vht-deployment-order # Show recommended order
```

### **Maintenance:**
```bash
make clean-vht-terraform      # Clean Terraform cache
make format-vht-terraform     # Format Terraform files
make extract-vht-all-info     # Extract all project outputs
```

## 🔥 **Destroy Commands**

### **Destroy in Reverse Order:**
```bash
make destroy-vht-all                    # Destroy everything (safe order)
make destroy-vht-payer-propensity-complete  # Destroy one complete project
```

## ⚠️ **Important Notes**

1. **Dependencies**: Claims lakehouse must be deployed first
2. **Order Matters**: Use grouped targets or `deploy-vht-all` for proper sequencing
3. **State Isolation**: Each component maintains separate Terraform state
4. **DAIVI Compliance**: All targets follow DAIVI IaC patterns

### Step 6: Manual Deployment (Alternative)

If you prefer manual deployment following DAIVI patterns:

```bash
# Deploy SageMaker component manually
cd iac/roots/sagemaker/vht-payer-propensity-producer
terraform init
terraform plan
terraform apply

# Deploy DataZone component manually
cd iac/roots/datazone/dz-vht-payer-propensity-producer  
terraform init
terraform plan
terraform apply

# Deploy DataLake component manually
cd iac/roots/datalakes/vht_claims_lakehouse
terraform init
terraform plan
terraform apply
```

### Step 7: Verify Deployments

#### 7.1 Check Component State Files

```bash
# Verify Terraform state files exist
ls -la iac/roots/sagemaker/*/terraform.tfstate
ls -la iac/roots/datazone/*/terraform.tfstate
ls -la iac/roots/datalakes/*/terraform.tfstate
```

#### 7.2 Check AWS Resources

```bash
# Verify SageMaker projects
aws sagemaker list-projects

# Verify DataZone projects  
aws datazone list-projects --domain-identifier YOUR_DOMAIN_ID

# Verify Glue databases
aws glue get-databases
```

#### 7.3 Check Cross-References in SSM

```bash
# Check project references
aws ssm get-parameters-by-path --path "/vhtds/dev/projects/"

# Check datalake references
aws ssm get-parameters-by-path --path "/vhtds/dev/datalakes/"
```

## Component Structure Verification

Verify that generated components follow DAIVI IaC best practices:

### ✅ **Modular Design**
- Components only reference modules from `../../templates/modules/`
- No direct resource configurations in component files
- All resources created through template modules

### ✅ **Component Structure**
- Each component has standard files: `main.tf`, `variables.tf`, `outputs.tf`
- Backend configuration in `backend.tf` for proper state management
- Provider configuration following DAIVI patterns

### ✅ **State Management**
- Each component maintains its own state file
- Remote state storage in S3 with DynamoDB locking
- State isolation between components

## Troubleshooting

### Common Issues

#### 1. Template Module Not Found
```bash
# Error: Module not found: ../../templates/modules/sagemaker-project
# Solution: Verify DAIVI foundation includes required template modules
ls -la iac/templates/modules/
```

#### 2. Backend Configuration Errors
```bash
# Error: Backend bucket does not exist
# Solution: Ensure DAIVI backend is deployed
make deploy-tf-backend-cf-stack
```

#### 3. SSM Parameter Not Found
```bash
# Error: Parameter /app/env/smus_domain_id not found
# Solution: Ensure DAIVI domain components are deployed
make deploy-domain-all
```

### Component Validation

```bash
# Validate component Terraform syntax
cd iac/roots/sagemaker/vht-payer-propensity-producer
terraform validate

# Check component references
grep -r "../../templates/modules/" iac/roots/
```

## Best Practices Followed

The generated components follow DAIVI IaC best practices:

1. **Modular Design**: All components reference existing template modules
2. **Component Structure**: Standard file organization and naming
3. **State Management**: Proper backend configuration for each component
4. **Code Organization**: Clean, focused configurations
5. **Documentation**: Clear variable and output descriptions
6. **Version Control**: Consistent formatting and naming conventions

## Security Considerations

1. **State File Security**: Backend state files encrypted and locked
2. **IAM Roles**: Components use existing DAIVI IAM roles and policies
3. **Resource Isolation**: Each component maintains separate state
4. **Access Control**: Following existing DAIVI security patterns

## Next Steps

After successful deployment:

1. **Configure Data Sources**: Set up data pipelines for healthcare data
2. **Train ML Models**: Use SageMaker projects for model development
3. **Configure RAG Applications**: Set up knowledge bases and chat interfaces
4. **Monitor Performance**: Use CloudWatch and DAIVI monitoring patterns
5. **Scale Resources**: Adjust instance types and configurations as needed

---

**Note**: This guide follows DAIVI IaC best practices where components are generated as infrastructure files only, and deployment is performed manually following established DAIVI patterns. The generator creates modular, reusable components that integrate seamlessly with existing DAIVI infrastructure.
