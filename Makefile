upload-docker:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 110745363067.dkr.ecr.us-east-1.amazonaws.com
	docker build -t chatbot-milhas-dev  --platform=linux/amd64 --provenance=false .
	docker tag chatbot-milhas-dev:latest 110745363067.dkr.ecr.us-east-1.amazonaws.com/chatbot-milhas-dev:latest
	docker push 110745363067.dkr.ecr.us-east-1.amazonaws.com/chatbot-milhas-dev:latest