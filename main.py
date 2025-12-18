from fastapi import FastAPI
from pydantic import BaseModel
from my_agent.agent import root_agent
from google.adk.sessions import InMemorySessionService
from google.adk.runners import Runner
from google.genai import types

app = FastAPI()

class AgentInput(BaseModel):
    input: str

@app.post("/run-agent")
async def run_my_agent(data: AgentInput):
    user_query = data.input

    # Cria serviço de sessão (memória)
    session_service = InMemorySessionService()
    user_id = "user"
    session_id = "session"

    session = await session_service.create_session(
        app_name="my_app", user_id=user_id, session_id=session_id
    )

    # Cria o runner do agent
    runner = Runner(
        agent=root_agent,
        app_name="my_app",
        session_service=session_service
    )

    content = types.Content(role="user", parts=[types.Part(text=user_query)])
    final_response = ""
    
    # Executa de forma assíncrona e coleta o evento final
    async for event in runner.run_async(
        user_id=user_id,
        session_id=session_id,
        new_message=content
    ):
        if event.is_final_response():
            if event.content and event.content.parts:
                final_response = event.content.parts[0].text
            break

    return {"resposta": final_response}
