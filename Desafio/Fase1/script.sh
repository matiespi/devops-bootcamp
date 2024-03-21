#!/bin/bash

#Se reciben variables y se guardan para usarse
nom_ape=$1
departamento=$2
temporalPassword=$3

#Convierte texto a minuscula
user_minuscula="${nom_ape,,}"
#Se separa palabra con _
user_create="${user_minuscula// /_}"

sudo groupadd ${departamento}

sudo useradd -m -c "${nom_ape}, ${departamento}" "${user_create}"

echo "${user_create}:${temporalPassword}" | sudo chpasswd

#Se estable vencimiento de clave temporal para en 30 dias
sudo chage -d 30 $user_create

sudo usermod -aG ${departamento} ${user_create} 

echo "${user_create}"

