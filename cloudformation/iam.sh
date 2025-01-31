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
    --policy-arn arn:aws:iam::558846430793:policy/EKSManagerEKSFullAccessPolicy



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
                "Resource": "arn:aws:lambda:ap-northeast-2:558846430793:function:*"
            }
        ]
    }'

aws iam attach-role-policy --role-name EKSManagerNodeUpgradeSchedulerRole \
    --policy-arn arn:aws:iam::558846430793:policy/EventBridgeSchedulerExecutionPolicy-EKSManagerNodeUpgrade


