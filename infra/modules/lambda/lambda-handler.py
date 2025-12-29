import json
import boto3
import os

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    RESPONSE_TOPIC_ARN = os.environ.get('RESPONSE_TOPIC_ARN')
    
    if not event.get('Records'):
        return {'statusCode': 400, 'body': 'Evento sem Records'}

    for record in event['Records']:
        user_msg = record['Sns']['Message']
        response_msg = f"RESPOSTA PROCESSADA: {user_msg.upper()}"
        
        sns_client.publish(
            TopicArn=RESPONSE_TOPIC_ARN,
            Message=response_msg
        )
        print(f"Publicado no Fan-out em uppercase: {response_msg}")
        
    return {'statusCode': 200, 'body': json.dumps('Processado em Uppercase!')}