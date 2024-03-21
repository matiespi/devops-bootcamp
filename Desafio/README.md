Pasos para poder ejecutar pipeline:

Darles permisos a jenkins para ejecutar sudo sin passwd:
- 
Ejecutar: sudo visudo
Ir a final del archivo y agregar la siguiente linea --> jenkins ALL=(ALL:ALL) NOPASSWD:ALL

En Jenkins,
1) Revisar que este instalado el plugin de "Extended E-mail Notification" o en su defecto actualizado
   
2) Ir a "Administrar Jenkins" - Credentials.
   Agregar credenciales con opcion "Username with password"
   En username agregar el correo remitente (que va a enviar el mail notificando al usuario)
   En password agregar la contraseña de aplicaciones creada desde la cuenta de mail.
   
3) - Ir a "Administrar Jenkins" - System
   Buscar el apartado "Jenkins Location" - en "System Admin e-mail address" poner nombre con que va llegar el correo:
   Ej: Jenkins <mail@mail.com>

  - En "System" tambien buscar "Extended E-mail Notification":
    Agregar configuracion de smtp server deseado, en "Avanzado" agregar las credenciales creadas anteriormente en el paso 2

------------------------------------------------------------------------------------------------------------------------------

EJECUCION DE JOB:
El job cuenta con dos simples parametros:
- Nombre y apellido --- A partir de estos datos el job creara el usuario
- Mail --- Se debera ingresar el mail de usuario en donde se informara los datos de ingreso
- Departamento ---- A traves de un choice se debera elegir el departamento que pertenece el usuario a crear

  Al finalizar el job debe llegar el mail con los datos.
   
