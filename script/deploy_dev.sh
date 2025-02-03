#!/bin/bash

S3_BUCKET="bys-dev-ue1-s3-eks-manager"
S3_PATH="node"
BASE_DIRECTORY="node-upgrade"
APP_NAME="node_upgrade"
PACKAGE_NAME="eks_node_manager"
CFN_NAME="cfn-node-upgrade.yaml"

rm -rf ../package ../${PACKAGE_NAME}.zip
rm -rf ../lambda_function.py
mkdir ../package

pip install --target ../package -r ../requirements.txt

cd ../package
zip -r ../${PACKAGE_NAME}.zip .

cd ..
cp ${APP_NAME}_lambda_function.py lambda_function.py
zip ${PACKAGE_NAME}.zip lambda_function.py
zip -r ${PACKAGE_NAME}.zip ${APP_NAME}.py

aws s3 cp ${PACKAGE_NAME}.zip s3://${S3_BUCKET}/${S3_PATH}/
aws s3 cp cloudformation/dev/${CFN_NAME} s3://${S3_BUCKET}/${S3_PATH}/

rm -rf lambda_function.py
rm -rf ${PACKAGE_NAME}.zip

#aws lambda update-function-code --function-name PVRE-EKSNodeGroupAutoManagement --s3-bucket bys-dev-ap2-s3-eks-manager --s3-key node/eks_addon_manager.zip
