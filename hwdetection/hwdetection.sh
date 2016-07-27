#!/bin/bash

############################################################################
#title           : hwdetection
#description     : detecta el hw de un pc y comprueba si ha cambiado
#author          : Óscar Borrás
#email           : oscarborras@iesjulioverne.es
#date            : 2016-07-14
#version         : 0.1
#license         : GNU GPLv3 
############################################################################



############################################################################
#  INSTRUCCIONES
############################################################################
# 


############################################################################
#  FALLOS POR CORREGIR
############################################################################
#
# 

############################################################################
#  FUNCIONES PENDIENTES DE IMPLEMENTAR
############################################################################
#
# 


############################################################################
# LISTA DE ESTADOS DE EXIT:
############################################################################
# 0   - Ok

############################################################################
# Inicialización de variables configurables
############################################################################
MEMORIA=""
DISCO=""

############################################################################
# BLOQUE FUNCIONES
############################################################################

# Función que averigua el hardware de un pc
# Uso:
function comprobar_hw_pc(){

#memoria
MEMORIA=`cat /proc/meminfo | grep -i memtotal | awk {'print $2 " " $3'}`

#disco duro
DISCO=`lsblk -fm`
}

function Main(){
	logger -p user.info -t backup_HTPC "Iniciado script backup HTPC."

	if actualizar_repositorio
		Main();
	comprobar_hw_pc();
	
	if cambiadoHW
		enviarEmail();
		
#	while true ; do
#		sleep 1d
#	done
	logger -p user.info -t backup_HTPC "Backup HTPC Finalizado."
}

############################################################################
# FIN BLOQUE FUNCIONES
############################################################################

#para permitir que se cargue el sistema completo hacemos una pausa
#sleep 1m

#if [[ $EUID -ne 0 ]]; then
#	echo "Este script debe ser ejecutado por el usuario root" > $TTY_SALIDA
#	logger -p user.err -t backup_diskusb_IES "Script NO ejecutado como root"
#	exit 1
#fi

#Llamada a la función Main que inicia el script
Main
