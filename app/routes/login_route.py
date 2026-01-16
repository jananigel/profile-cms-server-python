from fastapi import APIRouter
from app.schemas import LoginRequest, LoginResponse

router = APIRouter(prefix='/auth', tags=['Auth'])

@router.post('/login', response_model=LoginResponse)
def login(data: LoginRequest) -> LoginResponse:
  return LoginResponse(result='success')
