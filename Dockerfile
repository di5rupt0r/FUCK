# Dockerfile - Versão 1
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y --no-install-recommends coreutils && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y redis-tools
COPY . .
CMD ["tail", "-f", "/dev/null"]