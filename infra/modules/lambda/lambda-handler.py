import json
import boto3
import os
import http.client

def lambda_handler(event, context):
    # O endereço do seu ECS (ex: DNS do Load Balancer ou IP)
    # Recomendo passar isso via variável de ambiente no Terraform
    ECS_ENDPOINT = os.environ.get('ECS_ENDPOINT') 
    
    for record in event['Records']:
        msg_original = record['Sns']['Message']
        
        # Preparando a chamada para o ECS (FastAPI)
        # Exemplo usando http.client (padrão do Python) para não precisar de Layers extras
        try:
            conn = http.client.HTTPConnection(ECS_ENDPOINT)
            payload = json.dumps({"texto": msg_original})
            headers = {'Content-type': 'application/json'}
            
            # Chamando a rota do seu agente (ex: /processar)
            conn.request("POST", "/processar", payload, headers)
            response = conn.getresponse()
            data = response.read()
            
            print(f"ECS respondeu com status: {response.status}")
        except Exception as e:
            print(f"Erro ao conectar no ECS: {str(e)}")
            
    return {'statusCode': 200}