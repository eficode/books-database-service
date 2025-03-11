from fastapi import APIRouter, HTTPException
import uuid

router = APIRouter()
demo_sessions = {}

@router.post("/demo-mode/start")
def start_demo_mode():
    demo_session_id = str(uuid.uuid4())
    demo_sessions[demo_session_id] = True
    return { "message": "Demo mode started", "demoSessionId": demo_session_id }

@router.post("/demo-mode/stop")
def stop_demo_mode(demoSessionId: str):
    if demoSessionId in demo_sessions:
        del demo_sessions[demoSessionId]
        return { "message": "Demo mode stopped" }
    else:
        raise HTTPException(status_code=404, detail="Demo session not found")
