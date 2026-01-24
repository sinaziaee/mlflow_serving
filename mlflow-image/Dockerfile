FROM python:3.11-slim

RUN pip install --no-cache-dir \
    mlflow==2.14.3 \
    psycopg2-binary==2.9.9 \
    boto3==1.34.162

EXPOSE 5000

# We'll pass backend/artifact config via env vars in ECS
CMD ["sh", "-c", "mlflow server --host 0.0.0.0 --port 5000 --backend-store-uri \"$MLFLOW_BACKEND_STORE_URI\" --default-artifact-root \"$MLFLOW_DEFAULT_ARTIFACT_ROOT\""]
