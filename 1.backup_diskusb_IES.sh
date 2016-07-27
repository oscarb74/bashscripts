#!/bin/bash

############################################################################
#title           : backup_diskusb_IES
#description     : realización de copia de seguridad de mis datos del trabajo
#author          : Óscar Borrás
#email           : oscarborras@iesjulioverne.es
#date            : 2014-05-08
#version         : 0.8
#license         : GNU GPLv3 
############################################################################



############################################################################
#  INSTRUCCIONES
############################################################################
# Para añadir nuevos directorios a salvaguardar solo es necesario añadir
# la ruta en la variable DIRS_COPIAR o DIRS_COPIAR_HISTORICO


############################################################################
#  FALLOS POR CORREGIR
############################################################################
#
# 

############################################################################
#  FUNCIONES PENDIENTES DE IMPLEMENTAR
############################################################################
#
# - Usar un solo fichero log con rotación
# - Usar YAD en vez de zenity
# - Automontar particiones.
# - Hacer que el nombre del fichero log sea uno si se ha realizado satisfactoriamente (backup_OK_date) y otro si no (backup_ERROR_date).???
# - Envío de email resumen ¿en caso de fallo?.?
# - Detectar falta de espacio en disco o disco lleno en el destino o AVISAR cuando quede menos de un porcentaje 10% por ejemplo


############################################################################
# LISTA DE ESTADOS DE EXIT:
############################################################################
# 0   - Ok

############################################################################
# Inicialización de variables configurables
############################################################################

FICH_FECHA_BACKUP="/home/oscar/bashtools/lastbackup.date"
DIAS_MAX_SIN_BACKUP=5
DATE_LOG=`date +"%Y-%m-%d_%H:%M:%S"`;
LOG="/var/log/bashtools/misbackup/backupCF.log"	#Fichero log del programa

DISK_USB="SAMSUNG"          #Etiqueta Disco USB trabajo "SAMSUNG"
DISK_BACKUP="Backup"        #Etiqueta Disco Backup externo 160GB

DIR_BACKUP="/media/oscar/Backup/2.backup_CF"	  #Directorio destino del backup

# array de dir a salvaguardar sin histórico
DIRS_COPIAR=("/media/oscar/SAMSUNG/CF/1.Mat.Docente" \
				"/media/oscar/SAMSUNG/CF/0.Doc Profesor" \
				"/media/oscar/SAMSUNG/Mis cosas/Mis Programas" \
) 

# array de dir a salvaguardar manteniendo los ficheros borrados o modificados en el backup
DIRS_COPIAR_HISTORICO=("/media/oscar/SAMSUNG/CF/2.Normativas")

# array de dirs de recup para cada una de los dirs de la var DIRS_COPIAR_HISTORICO. 
# Debe coincidir en la misma pos. que DIRS_COPIAR_HISTORICO
DIRS_RECUP_HISTORICO=("$DIR_BACKUP/0.recuperacion/2.Normativas/`date -I`")

TOTAL_DIRS=`expr ${#DIRS_COPIAR[*]} + ${#DIRS_COPIAR_HISTORICO[*]}`  #Num total de directorios a copiar

CONTADOR=0  #Contador de directorios copiados

TTY_SALIDA="/dev/pts/0" #guake. Poner /dev/null si no desea salida en una terminal. La terminal debe existir
DISPLAY=":0"  #shell gráfica donde enviar las ventanas gráficas


############################################################################
# BLOQUE FUNCIONES
############################################################################

# Función que averigua el numero de días desde el ultimo backup
# Uso: obtener_fecha_ultimo_backup
# return=1 --> no se ha realizado ningun backup o no existe el fichero con la fecha del ultimo backup
# return=X --> donde X es el numero de dias desde el ultimo backup
function obtener_ndias_ultimo_backup(){
	local  ndias_lastbackup='-1'  #variable que almacena el num dias desde el ultimo backup. -1 si no se ha realizado nunca
	if [ -f $FICH_FECHA_BACKUP ]  
	then
		fecha_lastbackup=`cat $FICH_FECHA_BACKUP | awk '{print $1}'`  #fecha ultimo backup
		fecha_actual=`date +%Y%m%d`
		ndias_lastbackup=$(( ($(date --date $fecha_actual +%s) - $(date --date $fecha_lastbackup +%s) )/(60*60*24) ))
	fi
	echo "$ndias_lastbackup" #return de la función
}

# Función que actualiza la fecha del ultimo backup realizado
# Uso: actualizar_fecha_ultimo_backup
function actualizar_fecha_ultimo_backup(){
	fecha_actual=`date +%Y%m%d`
	echo $fecha_actual > $FICH_FECHA_BACKUP
}


function Main(){
	logger -p user.info -t backup_diskusb_IES "Iniciado script backup Disco USB IES."
#	while true ; do
	ndias_lastbackup=`obtener_ndias_ultimo_backup`		

	if [ $ndias_lastbackup -ge $DIAS_MAX_SIN_BACKUP ] ||  [ $ndias_lastbackup -eq -1 ]
	then
		iniciar_proceso
	fi
#		sleep 1d
#	done
#	logger -p user.info -t backup_diskusb_IES "Backup Disco USB IES Finalizado."
}

function mostrar_ventana_inicial(){
	disk_src_mount=`comprobar_dev_montado $DISK_USB`
	disk_bak_mount=`comprobar_dev_montado $DISK_BACKUP`
	
	if [ $disk_src_mount -eq 1 ]  
	then
		disk_src=" <span color='blue'><b>Montado</b></span>"
	else
		disk_src=" <span color='red'><b>NO montado</b></span>"
	fi
	
	if [ $disk_bak_mount -eq 1 ]  
	then
		disk_bak=" <span color='blue'><b>Montado</b></span>"
	else
		disk_bak=" <span color='red'><b>NO montado</b></span>"
	fi
	
	disk_espacio_total=` df -h | grep Backup | awk '{ print $2 }'`
	disk_espacio_libre=` df -h | grep Backup | awk '{ print $4 }'`
	disk_espacio_ocupado=` df -h | grep Backup | awk '{ print $5 }'`
	
	texto="\nSe va a realizar una copia de seguridad del disco USB del IES. \n\n"
	texto=$texto"<b>¿Desea realizar la copia ahora?</b> En caso afirmativo encienda el disco de backup externo.\n" 
	texto=$texto"\n--> Nº días desde último backup: <span color='blue'><b>$ndias_lastbackup</b></span>" 
	texto=$texto"\n--> Disco USB origen:$disk_src" 
	texto=$texto"\n--> Disco USB destino:$disk_bak \n" 
	if [ $disk_bak_mount -eq 1 ]  
	then
		texto=$texto"\n--> Espacio disponible en disco Backup: \n"
		texto=$texto"       <span color='blue'><b>$disk_espacio_libre de $disk_espacio_total ($disk_espacio_ocupado ocupado)</b></span>\n" 
	fi

	frmdata=$(yad --form --center --image /usr/share/icons/Mint-X/actions/48/help-about.png --image-on-top \
		--title "Copia de seguridad programada Disco IES" \
		--text "$texto" \
		--field ":LBL" \
		--field "¿Apagar el equipo tras finalizar backup?:CHK" FALSE  \
		--field "¿Envío de email en caso de fallo? (No implementado):CHK" FALSE \
		--button="Sí:0" --button="No:1" --button="Actualizar ventana:2"\
		--display=$DISPLAY)

	frm_button=$?  #recogemos la salida de yad, es decir, el ID del boton pulsado.
	frm_shutdown=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $3 }')
	frm_email=$(echo $frmdata | awk 'BEGIN {FS="|" } { print $2 }')
}

function iniciar_proceso(){
	mostrar_ventana_inicial

	case $frm_button in
		0)
			if [ $disk_src_mount -eq 1 ]  && [ $disk_bak_mount -eq 1 ]  #estan los dispositivos montados
			then
				iniciar_backup
				actualizar_fecha_ultimo_backup

				#Comprobamos checkbox de email marcado
				if test $frm_email == TRUE
				then
					echo
					#no implementado todavía
				fi

				#Comprobamos checkbox de apagado marcado
				if test $frm_shutdown == TRUE
				then
					shutdown -h +1  #apagar en 1 min.
				fi
			else   # NO estan los dispositivos montados
				echo "[ `date +%Y-%m-%d_%H:%M:%S` :Error] HDD no montado." | tee "$TTY_SALIDA" >> $LOG
				/usr/bin/zenity --error --title "Error: Copia de seguridad programada." --text '\n¡ERROR!: HDD no montado.' --display=$DISPLAY
			fi
		;;

		1)
			echo "[ `date +"%Y-%m-%d_%H:%M:%S"` :Info] Backup cancelado por el usuario." > "$TTY_SALIDA"
		;;

		2)
			iniciar_proceso
		;;
	esac
}

# Función que comprueba si están montados el dispositivo que se le pase por parametro
# Uso: comprobar_dev_montados <etiqueta del dispositivo USB>
# return=0 --> no está montado.
# return=1 --> está montado.
comprobar_dev_montado(){
	local  func_result='0'  #variable que almacena 0 si no esta montado el dev y 1 si lo están.

	oldIFS=$IFS     # conserva el separador de campo
	IFS=$'\n'       # nuevo separador de campo, el caracter fin de línea
	for dev in `cat /proc/mounts | grep $1`
	do
		if test ! -z $dev
		then
			func_result='1'
		fi
	done
	IFS=$old_IFS     # restablece el separador de campo predeterminado
	echo "$func_result" #return de la función
}


# Función que realiza el proceso de copia normal del directorio pasado como parámetro
# Uso: realizar_backup_normal <DIR_COPIAR> <DIR_DESTINO>
realizar_backup_normal(){	
	#incrementamos el contador de copias realizadas
	CONTADOR=`expr $CONTADOR + 1`  

	#creo fichero temporal para almacenar el tiempo que tarda en hacerse el backup
	fich_tmp=$(mktemp /tmp/backup_time.XXXXX)
	
	echo "" | tee "$TTY_SALIDA" >> $LOG	 
	echo "------------------------------------------------------------------------" | tee "$TTY_SALIDA" >> $LOG
	echo "[ `date +"%Y-%m-%d_%H:%M:%S"` :Info] Iniciando Backup $CONTADOR/$TOTAL_DIRS ..." | tee "$TTY_SALIDA" >> $LOG
	echo "Directorio a Copiar: $1" | tee "$TTY_SALIDA" >> $LOG
	echo "Directorio Destino: $2" | tee "$TTY_SALIDA" >> $LOG
	echo "Tipo backup: normal" | tee "$TTY_SALIDA" >> $LOG
	echo "------------------------------------------------------------------------" | tee "$TTY_SALIDA" >> $LOG
	/usr/bin/time -f %E -o $fich_tmp rsync -avz --delete-after "$1" "$2"/ | tee "$TTY_SALIDA" >> $LOG
	echo "Tiempo de proceso: `cat $fich_tmp`" | tee "$TTY_SALIDA" >> $LOG
	echo "" | tee "$TTY_SALIDA" >> $LOG

	#elimino el fichero temporal
	rm $fich_tmp
}

# Función que realiza el proceso de copia normal del directorio pasado como parámetro
# Uso: realizar_backup_con_historico <DIR_COPIAR> <DIR_DESTINO> <DIR RECUP>
#sin terminar
realizar_backup_con_historico(){	
	#incrementamos el contador de copias realizadas
	CONTADOR=`expr $CONTADOR + 1`  

	#creo fichero temporal para almacenar el tiempo que tarda en hacerse el backup
	fich_tmp=$(mktemp /tmp/backup_time.XXXXX)
	
	echo "" | tee "$TTY_SALIDA" >> $LOG	 
	echo "------------------------------------------------------------------------" | tee "$TTY_SALIDA" >> $LOG
	echo "[ `date +"%Y-%m-%d_%H:%M:%S"` :Info] Iniciando Backup $CONTADOR/$TOTAL_DIRS ..." | tee "$TTY_SALIDA" >> $LOG
	echo "Directorio a Copiar: $1" | tee "$TTY_SALIDA" >> $LOG
	echo "Directorio Destino: $2" | tee "$TTY_SALIDA" >> $LOG
	echo "Tipo backup: con historico" | tee "$TTY_SALIDA" >> $LOG
	echo "------------------------------------------------------------------------" | tee "$TTY_SALIDA" >> $LOG
	/usr/bin/time -f %E -o $fich_tmp rsync -avz --delete --backup --backup-dir="$3" "$1" "$2"/ | tee "$TTY_SALIDA" >> $LOG
	echo "Tiempo de proceso: `cat $fich_tmp`" | tee "$TTY_SALIDA" >> $LOG
	echo "" | tee "$TTY_SALIDA" >> $LOG

	#elimino el fichero temporal
	rm $fich_tmp
}


# Función que lanza la copia de todos los directorios a salvaguardar
# Uso: iniciar_backup
iniciar_backup(){	
	echo "" | tee "$TTY_SALIDA" >> $LOG
	echo "" | tee "$TTY_SALIDA" >> $LOG
	echo "***************************************************************************" | tee "$TTY_SALIDA" >> $LOG
	echo "[" `date +%Y-%m-%d_%H:%M:%S` ":Info] ###### Iniciando proceso de backup #######" | tee "$TTY_SALIDA" >> $LOG
	echo "***************************************************************************" | tee "$TTY_SALIDA" >> $LOG

#echo "Number of items in original array: ${#array[*]}"
	for ix in ${!DIRS_COPIAR[*]}
	do
		realizar_backup_normal "${DIRS_COPIAR[$ix]}" "$DIR_BACKUP"
	done

	for ix in ${!DIRS_COPIAR_HISTORICO[*]}
	do
		realizar_backup_con_historico ${DIRS_COPIAR_HISTORICO[$ix]} $DIR_BACKUP ${DIRS_RECUP_HISTORICO[$ix]}
	done

	echo "" | tee "$TTY_SALIDA" >> $LOG
	echo "***************************************************************************" | tee "$TTY_SALIDA" >> $LOG
	echo "[ `date +"%Y-%m-%d_%H:%M:%S"` :Success] ###### Backup finalizado ######" | tee "$TTY_SALIDA" >> $LOG
	echo "***************************************************************************" | tee "$TTY_SALIDA" >> $LOG	
}


############################################################################
# FIN BLOQUE FUNCIONES
############################################################################

#para permitir que se cargue el sistema completo hacemos una pausa
sleep 1m

#if [[ $EUID -ne 0 ]]; then
#	echo "Este script debe ser ejecutado por el usuario root" > $TTY_SALIDA
#	logger -p user.err -t backup_diskusb_IES "Script NO ejecutado como root"
#	exit 1
#fi

#Llamada a la función Main que inicia el script
Main


