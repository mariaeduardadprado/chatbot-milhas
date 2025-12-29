import json

def lambda_handler(event, context):
    for record in event['Records']:
        message = record['Sns']['Message']
        print(f"DELIVERY: Enviando ao usuário final -> {message}")
        
    return {'statusCode': 200}