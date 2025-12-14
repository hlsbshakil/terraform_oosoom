# Code structure and function consolidation was assisted by Google Gemini 1.5 Flash (Dec 2025).

import json
import boto3
import os

sns = boto3.client('sns')
TOPIC_ARN = os.environ['TOPIC_ARN']

HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
}

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        action = body.get('action')
        email = body.get('email')

        if not action:
            return {'statusCode': 400, 'headers': HEADERS, 'body': json.dumps('Action required')}

        # --- ACTION: LIST ---
        if action == 'list':
            response = sns.list_subscriptions_by_topic(TopicArn=TOPIC_ARN)
            all_subs = response.get('Subscriptions', [])
            
            email_list = []
            for sub in all_subs:
                email_list.append({
                    'email': sub['Endpoint']
                })
            
            return {
                'statusCode': 200,
                'headers': HEADERS,
                'body': json.dumps({'emails': email_list})
            }

        # --- ACTION: SUBSCRIBE ---
        elif action == 'subscribe':
            if not email: 
                return {'statusCode': 400, 'headers': HEADERS, 'body': json.dumps('Email required')}
            
            # The subscribe call is idempotent.
            sns.subscribe(TopicArn=TOPIC_ARN, Protocol='email', Endpoint=email)
            message = f"Confirmation sent to {email}."

        # --- ACTION: UNSUBSCRIBE ---
        elif action == 'unsubscribe':
            if not email: 
                return {'statusCode': 400, 'headers': HEADERS, 'body': json.dumps('Email required')}
            
            response = sns.list_subscriptions_by_topic(TopicArn=TOPIC_ARN)
            all_subs = response.get('Subscriptions', [])
            
            sub_arn = None
            
            for sub in all_subs:
                if sub['Endpoint'] == email and sub['Protocol'] == 'email':
                    if sub['SubscriptionArn'] not in ('Deleted', 'PendingConfirmation'):
                        sub_arn = sub['SubscriptionArn']
                        break
            
            if sub_arn:
                sns.unsubscribe(SubscriptionArn=sub_arn)
                message = f"Removed {email}."
            else:
                message = f"Could not unsubscribe {email} (Pending, Deleted, or Not Found)."

        else:
            return {'statusCode': 400, 'headers': HEADERS, 'body': json.dumps('Invalid action')}

        # --- Final Success Response for Subscribe/Unsubscribe ---
        return {
            'statusCode': 200,
            'headers': HEADERS,
            'body': json.dumps({'message': message})
        }

    except Exception as e:
        print(f"Error in manage_email: {e}")
        return {'statusCode': 500, 'headers': HEADERS, 'body': json.dumps(str(e))}