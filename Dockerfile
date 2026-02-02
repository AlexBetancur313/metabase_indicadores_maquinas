FROM python:3.9-slim

# Instalar dependencias del sistema para PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Instalar librería de PostgreSQL para Python
RUN pip install --no-cache-dir psycopg2-binary

# Crear directorio de trabajo
WORKDIR /app

# Copiar el script del simulador
COPY simulator.py .

# Ejecutar el simulador
CMD ["python", "-u", "simulator.py"]