import json
import boto3
import os
from decimal import Decimal

table = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])

#Logic for the decimal encoder was developed with the help of ChatGPT. No option to set the data type type to integer directly in DynamoDB.
class DecimalEncoder(json.JSONEncoder):
    """Encodes Decimal objects as integers for JSON serialization."""
    def default(self, obj):
        if isinstance(obj, Decimal):
            # Convert Decimal object to standard integer
            return int(obj) 
        return super().default(obj) 

def lambda_handler(event, context):
    #CORS Fix was added with the help of ChatGPT
    HEADERS = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    }
    
    try:
        # 1. Fetch all items
        response = table.scan()
        items = response.get('Items', [])
        
        # 2. Sort items by expiryDate (handles missing dates by placing them last) (Still not working properly)
        items.sort(key=lambda x: str(x.get('expiryDate') or '9999-12-31'))
        
        # 3. Return serialized data, using the custom encoder.
        return {
            'statusCode': 200,
            'headers': HEADERS,
            'body': json.dumps(items, cls=DecimalEncoder)
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': HEADERS,
            'body': json.dumps({"error": str(e)})
        }