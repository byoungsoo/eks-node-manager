# DEV: 202949997891
# SHARED: 202949997891


aws iam create-role --role-name EKSManagerNodeUpgradeLambdaRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

aws iam create-policy --policy-name EKSManagerEKSFullAccessPolicy \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "eks:*",
                "Resource": "*"
            }
        ]
    }'

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMFullAccess

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeLambdaRole \
    --policy-arn arn:aws:iam::202949997891:policy/EKSManagerEKSFullAccessPolicy



aws iam create-role --role-name EKSManagerNodeUpgradeSchedulerRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "scheduler.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

aws iam create-policy --policy-name EventBridgeSchedulerExecutionPolicy-EKSManagerNodeUpgrade \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "lambda:InvokeFunction",
                "Resource": "arn:aws:lambda:ap-northeast-2:202949997891:function:*"
            }
        ]
    }'

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeSchedulerRole \
    --policy-arn arn:aws:iam::202949997891:policy/EventBridgeSchedulerExecutionPolicy-EKSManagerNodeUpgrade



# aws iam delete-role --role-name EKSManagerNodeUpgradeLambdaRole
# aws iam delete-role --role-name EKSManagerNodeUpgradeSchedulerRole
# aws iam delete-policy --policy-arn $(aws iam list-policies --query "Policies[?contains(PolicyName, 'EventBridgeSchedulerExecutionPolicy-EKSManagerNodeUpgrade')]" | jq -r ".[0].Arn")
# aws iam delete-policy --policy-arn $(aws iam list-policies --query "Policies[?contains(PolicyName, 'EKSManagerEKSFullAccessPolicy')]" | jq -r ".[0].Arn")
