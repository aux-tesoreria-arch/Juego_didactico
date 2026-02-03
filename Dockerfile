# Build Stage for Frontend
FROM node:18-slim AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN chmod -R +x node_modules/.bin
RUN npm run build

# Production Stage
FROM python:3.10-slim
WORKDIR /app

# Install dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn uvicorn

# Copy projects
COPY . .
# Copy the built frontend to the expected location for the backend
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# Environment variables
ENV PORT=8000

# Expose port
EXPOSE 8000

# Start command (using uvicorn for speed, gunicorn for multi-worker robustness)
CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT}"]
