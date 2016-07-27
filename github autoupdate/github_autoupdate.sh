#!/bin/bash

############################################################################
#title           : github_autoupdate.sh
#description     : script que muestra como auto actualizarse el script si está actualizado en github
#author          : Óscar Borrás
#email           : oscarborras@iesjulioverne.es
#date            : 27-07-2016
#version         : 1.0
#license         : GNU GPLv3 
############################################################################



############################################################################
#  INSTRUCCIONES
############################################################################
#1.- Instalaremos ethtool y configuraremos la interfaz de red para que la tarjeta se quede a la espera una vez apagado el PC. 
#sudo apt-get install ethtool

#2.- Configuraremos la interfaz de red para que la tarjeta se quede a la espera una vez apagado el PC. 
#sudo ethtool -s eth0 wol g

#3.- A continuación comprobamos que efectivamente se ha activado correctamente Introduciendo el comando
#sudo ethtool eth0
#Vemos en estas dos lineas que está activado
#
#Supports Wake-on: g
#         Wake-on: g

#4.- Persistencia
#debemos hacer que se ejecute en cada arranque el paso 2. Para ello:

#4.1.- Lo movemos a la carpeta de ejecución de scripts iniciales
#sudo mv wol_enable.sh /etc/init.d

#4.2.- Le otorgamos los permisos
#sudo chmod 755 /etc/init.d/wol_enable.sh

#4.3.- Le asignamos la propiedad
#Podemos saber nuestro usuario utilizando el comando 'who'
#sudo chown TU_USUARIO:TU_USUARIO /etc/init.d/wol_enable.sh

#4.4.- lo iniciamos como servicio a varios niveles gui command etc
#sudo update-rc.d wol_enable.sh defaults (debian)

############################################################################
#  FALLOS POR CORREGIR
############################################################################
#
# 

############################################################################
#  FUNCIONES PENDIENTES DE IMPLEMENTAR
############################################################################
#
# - Autoinstalación en el pc a arrancar



############################################################################
# LISTA DE ESTADOS DE EXIT:
############################################################################
# 0   - Ok

############################################################################
# Inicialización de variables configurables
############################################################################

INTERFACE="eth1"



ethtool -s $INTERFACE wol g
exit 0
