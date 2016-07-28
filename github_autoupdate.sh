#!/bin/bash

############################################################################
#title           : github_autoupdate.sh
#description     : script que muestra como auto actualizarse el script si está actualizado en github
#author          : Óscar Borrás
#email           : oscarborras@iesjulioverne.es
#date            : 28-07-2016
#version         : 0.3
#license         : GNU GPLv3 
############################################################################



############################################################################
#  INSTRUCCIONES
############################################################################
# El script se auto actualiza una vez al día como máximo.
# Se usa un repo en Github

############################################################################
#  FALLOS POR CORREGIR
############################################################################
#
# 

############################################################################
#  FUNCIONES PENDIENTES DE IMPLEMENTAR
############################################################################
#
# - 



############################################################################
# LISTA DE ESTADOS DE EXIT:
############################################################################
# 0   - Ok

############################################################################
# Inicialización de variables configurables
############################################################################
DIR_INSTALL="/root/.scripts"
FILE_LASTUPDATE="./github_autoupdate.date"
#CLONAR=0  #variable para saber si debemos clonar o no el repo. Por defecto 'no'.
DATE_LOG=`date +"%Y-%m-%d_%H:%M:%S"`;
LOG="./github_autoupdate.log"	#Fichero log del programa
TTY_SALIDA="/dev/pts/4" #guake. Poner /dev/null si no desea salida en una terminal. La terminal debe existir

############################################################################
# BLOQUE FUNCIONES
############################################################################

# Función que actualiza el repositorio a la ultima versión
# Uso: actualizar_repo
# return=1 --> no se ha realizado la clonación satisfactoriamente
function actualizar_repo(){
	git pull
	
	#si se clona actualizar fichero con fecha de hoy
	date +%Y%m%d > $FILE_LASTUPDATE 
	
#	echo "0" #return de la función
}

# Función que clona el repositorio en local. Se debe realizar solo la primera vez
function clonar(){
	git clone  https://github.com/oscarb74/bashscripts.git
	
	#para ejecutar el script sincronizado con github
	cd bashscripts
	
	#si se clona actualizar fichero con fecha de hoy
	date +%Y%m%d > $FILE_LASTUPDATE 
	
	#eliminamos el script incial
	rm ../github_autoupdate.sh

#	echo "0" #return de la función
}


############################################################################
# Main
############################################################################

#comprobamos si debemos instalar el programa (hacer clonacion)
if [ -d .git ]  
then
	echo hola
	exit
fi
echo 1
exit
#comprobamos fecha ultima ejecucion
#si es distinta de hoy clonamos sino no. Para ello usar un fichero log o temporal
echo "------------------------------------------------------------------------" | tee "$TTY_SALIDA" >> $LOG
echo "[ `date +"%Y-%m-%d_%H:%M:%S"` :Info] Iniciando autoupdate ..." | tee "$TTY_SALIDA" >> $LOG
if [ -f $FILE_LASTUPDATE ]  
then
	fecha_lastbackup=`cat $FILE_LASTUPDATE`  #fecha ultima clonacion
	fecha_actual=`date +%Y%m%d`
	if [ $fecha_lastbackup != $fecha_actual ]
	then
		actualizar_repo
	fi
else
	clonar
fi
	


