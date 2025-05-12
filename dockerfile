# Dockerfile
FROM python:3.9-slim

# 1. Set a working directory
WORKDIR /app

# 2. Copy requirements and install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy your code/data
COPY src/ ./src/
COPY data/ ./data/
COPY .github/ ./ .github/  

# 4. Expose any ports your app uses (example: 5000)
EXPOSE 5000

# 5. Define default command (adjust if you have an entrypoint)
CMD ["python", "-u", "src/train_model.py"]
