from fastapi import FastAPI

app = FastAPI(title="my-first-devops-project")


@app.get("/")
def root():
    return {"message": "hello from my first devops project By Ajay Autade"}


@app.get("/health")
def health():
    return {"status": "ok"}
