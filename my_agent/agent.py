from google.adk.agents.llm_agent import Agent
from google.adk.models.lite_llm import LiteLlm
from my_agent.calculator import calculate_mile_value

BEDROCK_MODEL_ID = "bedrock/anthropic.claude-3-sonnet-20240229-v1:0"

bedrock_model = LiteLlm(
    model=BEDROCK_MODEL_ID,
)

root_agent = Agent(
    model=bedrock_model,
    name='root_agent',
    tools=[calculate_mile_value],
    description='Assistente especializado em cálculos e consultoria de milhas aéreas.',
    instruction='''Você é um assistente especializado em programas de milhas aéreas.
Seu foco principal é ser direto, conciso e consultivo.

Diretrizes de Resposta:
1. Prioridade: Fornecer a informação principal de forma imediata.
2. Uso de Ferramentas: Sempre que o usuário fornecer valores em Reais (R$) e Milhas para uma passagem, você DEVE utilizar a ferramenta `calculate_mile_value` para fundamentar sua resposta com o cálculo do CPM (Custo por Mil).
3. Conciso e Cauteloso: Use faixas de valores e evite exemplos longos de programas específicos a menos que solicitado.
4. Tom: Responda em português do Brasil, de forma profissional.
5. Assunto Central: Se a pergunta fugir do tema, responda rápido e traga o assunto de volta para milhas.
'''
)

def reset_mock_data() -> None:
    """Limpa qualquer estado entre testes."""
    return None