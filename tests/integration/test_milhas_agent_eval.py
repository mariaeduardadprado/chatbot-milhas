import asyncio
import importlib
import os
import sys
from pathlib import Path

from google.adk.evaluation.agent_evaluator import AgentEvaluator


def test_milhas_agent_eval():

    project_root = Path(os.getcwd()).resolve()
    if str(project_root) not in sys.path:
        sys.path.insert(0, str(project_root))

    module_name = "my_agent.agent"

    # Import do agente
    agent_module = importlib.import_module(module_name)

    # Reset de estado
    if hasattr(agent_module, "reset_mock_data"):
        agent_module.reset_mock_data()

    eval_file = project_root / "tests" / "integration" / "eval_milhas.test.json"

    if not eval_file.exists():
        raise FileNotFoundError(f"Arquivo de avaliação não encontrado: {eval_file}")

    asyncio.run(
        AgentEvaluator.evaluate(
            agent_module=module_name,
            eval_dataset_file_path_or_dir=str(eval_file),
            num_runs=1,
        )
    )