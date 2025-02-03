#aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/shared-ap2/shared-cfn-cdpl.json --region ap-northeast-2 --profile shared-admin
#aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/shared-ap2/shared-lambda-cdpl.json --region ap-northeast-2 --profile shared-admin

#aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/dev-ap2/dev-cfn-cdpl.json --region ap-northeast-2 --profile dev-admin
#aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/dev-ap2/dev-lambda-cdpl.json --region ap-northeast-2 --profile dev-admin

#aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/dev-ue1/dev-cfn-cdpl.json --region us-east-1 --profile dev-admin
aws codepipeline update-pipeline --cli-input-json file://../codeseries/cdpl/dev-ue1/dev-lambda-cdpl.json --region us-east-1 --profile dev-admin