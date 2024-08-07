import boto3
import time
import argparse

# Configuración de argparse para recibir parámetros
parser = argparse.ArgumentParser(description='Filtrar instancias EC2 y comprimir logs.')
parser.add_argument('--tag-key', required=True, help='Clave de la etiqueta para filtrar instancias EC2')
parser.add_argument('--tag-value', required=True, help='Valor de la etiqueta para filtrar instancias EC2')
parser.add_argument('--s3-bucket', required=True, help='Nombre del bucket de S3')
parser.add_argument('--region', required=True, help='Región de AWS')

args = parser.parse_args()

# Asignación de parámetros
AWS_REGION = args.region
TAG_KEY = args.tag_key
TAG_VALUE = args.tag_value
S3_BUCKET = args.s3_bucket

# Crear una sesión con AWS
session = boto3.Session(
    region_name=AWS_REGION
)

# Conectar al servicio EC2 y SSM
ec2 = session.client('ec2')
ssm = session.client('ssm')

# Filtrar instancias EC2 con la etiqueta específica
response = ec2.describe_instances(
    Filters=[
        {
            'Name': f'tag:{TAG_KEY}',
            'Values': [TAG_VALUE]
        }
    ]
)

# Procesar la respuesta para obtener los IDs y nombres de las instancias
instance_details = []
for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        instance_id = instance['InstanceId']
        instance_name = None
        for tag in instance.get('Tags', []):
            if tag['Key'] == 'Name':
                instance_name = tag['Value']
        if instance_name:
            instance_details.append({
                'InstanceId': instance_id,
                'InstanceName': instance_name
            })

if not instance_details:
    print(f"No se encontraron instancias con la etiqueta {TAG_KEY}={TAG_VALUE}")
    exit(0)

# Lista para almacenar los nombres de los archivos comprimidos
compressed_logs = []

# Enviar comandos SSM para comprimir logs y subir a S3
for detail in instance_details:
    instance_id = detail['InstanceId']
    instance_name = detail['InstanceName']

    # Nombre de archivo comprimido (solo fecha)
    timestamp = time.strftime("%Y%m%d")  # Formato de fecha YYYYMMDD
    compressed_log = f"logs_{instance_name}_{timestamp}.zip"

    # Comando SSM
    ssm_response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={
            "commands": [
                f"sudo zip -r /tmp/{compressed_log} /var/log",
                f"aws s3 cp /tmp/{compressed_log} s3://{S3_BUCKET}/"
            ]
        },
        TimeoutSeconds=60,
        Comment="Comprimir logs y subir a S3"
    )

    command_id = ssm_response['Command']['CommandId']

    # Esperar a que el comando se ejecute
    time.sleep(60)

    # Verificar si el archivo existe en S3
    s3 = session.client('s3')
    try:
        s3.head_object(Bucket=S3_BUCKET, Key=compressed_log)
        compressed_logs.append(compressed_log)  # Guardar el nombre del archivo comprimido
    except:
        print(f"Error: No se encontró el archivo {compressed_log} en el bucket S3.")

# Imprimir solo los nombres de archivos comprimidos, sin mensajes adicionales
for log in compressed_logs:
    print(log)
