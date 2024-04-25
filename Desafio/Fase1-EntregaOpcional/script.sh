#!/bin/bash

function nombre {
    echo -e "Informe del sistema para:\n$(hostname)"
}

function fecha {
    echo -e "Fecha del sistema:\n$(date "+%d-%m-%Y %H:%M:%S")"
}

function info {
    echo -e "Informacion del sistema:\n$(df -h | grep " /$")"
}

function usuario {
    echo -e "Usuario logueado:\n$(who)"
}

function disco {
    echo -e "Espacio de disco:\n$(free -h | awk 'NR==2{printf "Total: %s - Disponible: %s\n", $2, $7}')"

}

function procesos {

    parametro=$1

    echo -e "Proceso:\n$(ps -aux | grep "$parametro")"
}


main (){
    parametro=$1
    nombre
    fecha
    info
    usuario
    disco
    procesos $parametro
}

main $1
