#!/bin/bash

############################################################################
#title           : github_autoupdate.sh
#description     : script que muestra como auto actualizarse el script si está actualizado en github
#author          : Óscar Borrás
#email           : oscarborras@iesjulioverne.es
#date            : 27-07-2016
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
FILE_LASTUPDATE="./github_autoupdate.date"
#CLONAR=0  #variable para saber si debemos clonar o no el repo. Por defecto 'no'.


############################################################################
# BLOQUE FUNCIONES
############################################################################

# Función que averigua el numero de días desde el ultimo backup
# Uso: clonar
# return=1 --> no se ha realizado la clonación satisfactoriamente
function clonar(){
	#esta opcion falla la 2 vez. Buscar otro comando
	git clone  https://github.com/oscarb74/bashscripts.git
	
	#si se clona actualizar fichero con fecha de hoy
	date +%Y%m%d > $FILE_LASTUPDATE 
	
#	echo "0" #return de la función
}



############################################################################
# Main
############################################################################

#comprobamos fecha ultima ejecucion
#si es distinta de hoy clonamos sino no. Para ello usar un fichero log o temporal
if [ -f $FILE_LASTUPDATE ]  
then
	fecha_lastbackup=`cat $FILE_LASTUPDATE`  #fecha ultima clonacion
	fecha_actual=`date +%Y%m%d`
	if [ $fecha_lastbackup != $fecha_actual ]
	then
		clonar
	fi
else
	clonar
fi
	


