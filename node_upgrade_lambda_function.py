import node_upgrade
import json

def lambda_handler(event, context):

    try:
        node_upgrade.update_mng_nodegroup()
    except Exception as e:
        print(e)
        return {
            'body': json.dumps('Failed to update!')
        }
    else:
        return {
            'body': json.dumps('Success to update!')
        }

