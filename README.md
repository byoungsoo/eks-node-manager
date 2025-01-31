## Purpose
This code is for automatically managing EKS cluster. Two main operations will do.
1. Upgrade node AMI to latest automatically
2. Upgrade addon version automatically

## Install
At the frist time, it needs manual work once.
1. It needs to create S3 bucket manually. Ex: `bys-dev-s3-eks-manager`
2. It needs to create `CodeBuild` and `CodeDeploy` manually which both are using in lambda pipeline.
3. Run script/deploy_dev.sh script.
4. Create CodePipeline using codeseries/cdpl/dev/dev-cfn-cdpl.json. Refer to script/update_pipeline.sh script.
5. Create CodePipeline using codeseries/cdpl/dev/dev-lambda-cdpl.json. 

## Overview
Two main pipelines will be created in install step.  
1. `cfn` is for creating resource.  
2. `lambda` is for managing source code. 
