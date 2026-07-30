import json
import boto3
import os

localstack_host = os.environ.get('LOCALSTACK_HOSTNAME', 'localhost')
sns = boto3.client('sns', endpoint_url=f'http://{localstack_host}:4566', region_name='us-east-1')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:order-notifications'

def handler(event, context):
    for record in event['Records']:
        body = json.loads(record['body'])

        order_id = body.get('order_id')
        item = body.get('item')
        quantity = body.get('quantity')

        print(f"Processing order {order_id}: {quantity}x {item}")

        message = f"Order confirmed: Order #{order_id} ({quantity}x {item})"

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message
        )

        print(f"Notification sent: {message}")

    return {
        'statusCode': 200,
        'body': json.dumps('Orders processed')
    }
