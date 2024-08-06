# ... código anterior ...

# Lista para almacenar los nombres de los archivos comprimidos
compressed_logs = []

# Enviar comandos SSM para comprimir logs y subir a S3
for detail in instance_details:
    instance_id = detail['InstanceId']
    instance_name = detail['InstanceName']
    print(f"Procesando instancia {instance_id} ({instance_name})")

    # Nombre de archivo comprimido
    timestamp = time.strftime("%Y%m%d%H%M%S")
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
    print(f"Comando enviado a la instancia {instance_id}, Command ID: {command_id}")

    # Esperar a que el comando se ejecute
    time.sleep(60)

    # Verificar si el archivo existe en S3
    s3 = session.client('s3')
    try:
        s3.head_object(Bucket=S3_BUCKET, Key=compressed_log)
        print(f"Archivo {compressed_log} subido correctamente a S3.")
        compressed_logs.append(compressed_log)  # Guardar el nombre del archivo comprimido
    except:
        print(f"Error: No se encontró el archivo {compressed_log} en el bucket S3.")

# Imprimir todos los nombres de archivos comprimidos
for log in compressed_logs:
    print(log)
