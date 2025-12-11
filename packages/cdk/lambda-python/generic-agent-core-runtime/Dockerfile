# Use ARM64 base image for Bedrock AgentCore compatibility
FROM --platform=linux/arm64 public.ecr.aws/docker/library/python:3.13

WORKDIR /var/task

# Environment variables for UV package manager
ENV UV_NO_CACHE=1
ENV UV_NO_MANAGED_PYTHON=1
ENV UV_PYTHON=/usr/local/bin/python
ENV UV_INSTALL_DIR=/usr/local/bin
ENV UV_PROJECT_ENVIRONMENT=/tmp/.venv

# Install system dependencies (including AWS CLI for SSM access)
RUN apt-get update -y && apt-get install curl nodejs npm graphviz unzip -y
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy dependency files
COPY pyproject.toml .python-version uv.lock ./

# Install Python dependencies
RUN uv sync

# Copy application files
COPY app.py ./
COPY src/ ./src/

# Expose port 8080 as required by AgentCore
EXPOSE 8080

# Use entrypoint script to set up AWS credentials from SSM before starting the app
ENTRYPOINT ["/entrypoint.sh"]

# Start the application with OpenTelemetry instrumentation
CMD ["uv", "run", "opentelemetry-instrument", "python", "app.py"]
