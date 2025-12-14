import json
import boto3
import os

# Initialize table using a single line
table = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        # 1. Parse the request body
        body = json.loads(event.get('body', '{}'))
        doc_name = body.get('documentName') 

        if not doc_name:
            # Error if the required key is missing
            return {'statusCode': 400, 'body': json.dumps('Error: Missing documentName')}

        # 2. Delete the item using the documentName as the primary key
        table.delete_item(Key={'documentName': doc_name})

        # 3. Success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Deleted'})
        }
    
    except Exception as e:
        # Catch any other errors
        return {'statusCode': 500, 'body': json.dumps(str(e))}