import boto3
import os
import json
from datetime import datetime


dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = os.environ['TABLE_NAME']
TOPIC_ARN = os.environ['TOPIC_ARN']
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        today = datetime.now().date()
        print(f"Running Daily Check for {today}...")

        # DynamoDB Scan: Retrieve all items
        response = table.scan()
        documents = response.get('Items', [])
        alerts_sent = 0
        
        for doc in documents:
            name = doc.get('documentName', 'Unknown')
            expiry_str = doc.get('expiryDate')
            
            if doc.get('alertsEnabled') is False or not expiry_str:
                continue
           
            expiry_date = datetime.strptime(expiry_str, '%Y-%m-%d').date()
            alert_threshold = int(doc.get('alertDays', 30))

            days_left = (expiry_date - today).days

            message = None
            # 1. Expired Documents
            if days_left < 0:
                message = f"URGENT: '{name}' has EXPIRED! (Due: {expiry_str})"
            
            # 2. Upcoming Expiry Alerts
            elif 0 <= days_left <= alert_threshold:
                if days_left == 0:
                    message = f"URGENT: '{name}' EXPIRES TODAY!"
                else:
                    message = f"REMINDER: '{name}' expires in {days_left} days."
            
            # Send alert if a message was generated
            if message:
                print(f"Sending: {message}")
                sns.publish(
                    TopicArn=TOPIC_ARN,
                    Message=message,
                    Subject=f"Expiry Alert: {name}"
                )
                alerts_sent += 1

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(f"Check complete. Sent {alerts_sent} alerts.")
        }

    except Exception as e:
        print(f"Fatal Error: {e}")
        return {'statusCode': 500, 'body': json.dumps(str(e))}