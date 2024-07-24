#!/bin/bash

# Configurar la región de AWS
aws configure set region us-east-1 

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

# Obtén la lista de IDs de instancias EC2 que coinciden con la palabra clave
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=*$KEYWORD*" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Verifica que se hayan encontrado instancias
if [ -z "$INSTANCE_IDS" ]; then
    echo "ERROR: No se encontraron instancias con la palabra clave '$KEYWORD'."
    exit 1
fi

for INSTANCE_ID in $INSTANCE_IDS; do
    # Obtén el nombre DNS público de la instancia
    EC2_PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PublicDnsName" --output text)
    
    echo "Connecting to $EC2_PUBLIC_DNS"

    # Conéctate a la instancia, comprime los logs y copia el archivo de vuelta a la máquina local
    ssh -o StrictHostKeyChecking=no -i /path/to/your/private/key.pem ec2-user@$EC2_PUBLIC_DNS "sudo tar -czf /tmp/system-logs-$DATE.tar.gz $LOG_DIR"
    scp -i /path/to/your/private/key.pem ec2-user@$EC2_PUBLIC_DNS:/tmp/system-logs-$DATE.tar.gz /tmp/system-logs-$DATE-$INSTANCE_ID.tar.gz
    aws s3 cp /tmp/system-logs-$DATE-$INSTANCE_ID.tar.gz s3://$S3_BUCKET/system-logs-$DATE-$INSTANCE_ID.tar.gz
    ssh -i /path/to/your/private/key.pem ec2-user@$EC2_PUBLIC_DNS "sudo rm /tmp/system-logs-$DATE.tar.gz"
    rm /tmp/system-logs-$DATE-$INSTANCE_ID.tar.gz
done
