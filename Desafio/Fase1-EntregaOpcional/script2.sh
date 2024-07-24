#!/bin/bash

# Parámetro ingresado en el job de Jenkins
KEYWORD=${KEYWORD}

# Verifica que el parámetro no esté vacío
if [ -z "$KEYWORD" ]; then
  echo "ERROR: No se ha proporcionado ninguna palabra clave."
  exit 1
fi

# Define variables
LOG_DIR="/var/log"
S3_BUCKET="db-udemy"
DATE=$(date +%Y-%m-%d)

# Información del rol de IAM (reemplazar con valores reales)
ROLE_ARN="arn:aws:iam::678371350208:role/permisos-jenkins"
SESSION_NAME="JenkinsJob"

# Obtener la lista de ID de instancias con la palabra clave
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=*$KEYWORD*" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Comprobar si se encuentran instancias
if [ -z "$INSTANCE_IDS" ]; then
  echo "ERROR: No se encontraron instancias con la palabra clave '$KEYWORD'."
  exit 1
fi

for INSTANCE_ID in $INSTANCE_IDS; do
  # Asumir el rol de IAM para la instancia
  ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" --output text)
  
  # Extraer credenciales temporales de la salida
  ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
  SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
  SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

  # Usar credenciales temporales para acciones posteriores
  aws --access-key-id "$ACCESS_KEY_ID" --secret-access-key "$SECRET_ACCESS_KEY" --session-token "$SESSION_TOKEN" ec2 describe-instances --instance-ids $INSTANCE_ID &> /dev/null  # Verificar conectividad de la instancia (opcional)

  # Obtener el nombre DNS público (reemplazar con el comando real si es necesario)
  EC2_PUBLIC_DNS=$(aws --access-key-id "$ACCESS_KEY_ID" --secret-access-key "$SECRET_ACCESS_KEY" --session-token "$SESSION_TOKEN" ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PublicDnsName" --output text)

  echo "Conectando a $EC2_PUBLIC_DNS"

  # Usar credenciales temporales para comandos posteriores (por ejemplo, comprimir registros, copiar a S3)
  # ... (implementa tus comandos existentes usando credenciales temporales)
  # ...
   # Conéctate a la instancia, comprime los logs y copia el archivo de vuelta a la máquina local

done
