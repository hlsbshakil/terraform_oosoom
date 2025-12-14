import json, boto3, os

table = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))

        table.put_item(
            Item={
                'documentName': body.get('documentName'),
                'expiryDate': body.get('expiryDate'),
                'alertsEnabled': body.get('alertsEnabled', True),
                'alertDays': int(body.get('alertDays', 30))
            },
            ConditionExpression='attribute_not_exists(documentName)'
        )

        return {'statusCode': 200, 'body': json.dumps({'message': 'Saved'})}

    except Exception as e:
        return {'statusCode': 400, 'body': json.dumps(str(e))}