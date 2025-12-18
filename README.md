## Chatbot Especialista em Milhas (Agent ADK)
Este projeto consiste em um Agente de Inteligência Artificial especializado no mercado de milhas aéreas brasileiras. O agente não apenas tira dúvidas conceituais, mas também utiliza ferramentas (Tools) para realizar cálculos de viabilidade financeira em tempo real.

O projeto foi desenvolvido utilizando o Google Agent Development Kit (ADK) e o modelo Claude 3 (Anthropic) via Amazon Bedrock.

### Arquitetura do Sistema
O sistema é composto por quatro camadas principais:

Modelo (LLM): Amazon Bedrock (Anthropic Claude 3 Sonnet).

Cérebro (ADK): Gerencia o raciocínio, memória de sessão e execução de ferramentas.

API (FastAPI): Exposição do serviço para integração com interfaces web/mobile.

Infraestrutura (Docker): Isolamento completo do ambiente em contêineres.

### Funcionalidades Principais
Consultoria Didática: Explicações sobre CPM, milhas, pontos e programas de fidelidade.

Tool Calling (Cálculo de CPM): Uma ferramenta Python customizada que calcula o valor do milheiro.

Lógica: O agente identifica valores na pergunta do usuário e executa o cálculo: (Preço em Dinheiro - Taxas) / (Milhas / 1000).

Guardrails de Conteúdo: Instruções rigorosas para manter o foco no nicho de viagens e milhas.

Avaliação Automatizada: Suite de testes com Pytest e AgentEvaluator para medir a similaridade das respostas.

### Como Executar o Projeto
Pré-requisitos
Docker e Docker Compose instalados.

Credenciais da AWS configuradas (para acesso ao Bedrock).

**Passo a Passo
Subir o ambiente:**

docker compose up -d --build

Abra o navegador em: http://localhost:8000/docs

**Rodar os Testes de Avaliação:**

docker compose exec chatbot-api pytest tests/integration/test_milhas_agent_eval.py


### Estrutura de Pastas

├── my_agent/  
│   ├── agent.py         
│   └── calculator.py  
├── tests/  
│   └── integration/   
├── main.py   
├── Dockerfile   
└── docker-compose.yml  


### Estratégia de Testes
Os testes utilizam o AgentEvaluator para comparar as respostas da IA com referências ideais, utilizando a métrica response_match_score.

Threshold: Configurado em 0.3 para permitir a variabilidade natural da linguagem generativa, focando na precisão técnica dos dados fornecidos pela ferramenta de cálculo.

### Desenvolvedor
Projeto focado em demonstrar o ciclo de vida completo de um Agente de IA: Desenvolvimento, Integração, Conteinerização e Qualidade.