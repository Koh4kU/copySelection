#!/bin/bash

echo -e "\nNombre: `whoami`"
echo "Fecha: `date`"
echo -e "Bash version: $BASH_VERSION \n"
if [ $# -lt 3 ]
then
	echo "Numero incorrecto de argumentos, minimo 3"
	exit 2
fi
if ! [ -d $1  ]
then
	echo "El directorio a copiar no existe"
	exit 2
fi


NUMFICHEROS=0
DIRECTORIOS=`find "$1" -type d -wholename "$1*"`
#Se inicializa a -1 para que no cuente el propio directorio
NUMDIRECTORIOS=-1
CODIGOERROR=0
#Para poder empezar en el tercer argumento (o en cualquiera)
argv=("$@")

#Contamos los directorios que vamos a copiar
for i in $DIRECTORIOS
	do
		#Flag del directorio para saber si contabilizarlo o no
		SUMA=0
		#Guardamos en una varible el numero de lineas que tiene el ls en el directorio
		NUM=`ls $i | wc -l`
		#En caso de que el directorio este vacio, no se contabiliza (ya que no se va a copiar)
		if [ $NUM -ge 1 ]
			then
				#Usamos un bucle para buscar si dentro de un directorio hay algun archivo con la extension indicada para contabilizarlo
				#Bucle estandar de C para empezar en los argumentos que contienen las extensiones
				for (( j=2;j<$#;j++  ))
					do
						#En caso de que encontremos algun archivo con la extension indicada, debemos sumarle 1 al contador de directorios
						if [ `find "$i" -wholename "*.${argv[j]}" | wc -l` -ge 1 ]
							then
								SUMA=1
						fi
					done
				NUMDIRECTORIOS=$((NUMDIRECTORIOS + SUMA))
		fi
	done
#Recorremos con un bucle los argumentos del script, saltandonos los dos primeros, ya que solo nos interesa las extensiones que se van a copiar
for i in $@
	do
		if [ $i != $1 ]
			then
				if [ $i != $2 ]
				then
					#Copiamos el contenido que concuerde con los includes de $1 en $2 de forma recursiva conservando los permisos de los archivos y no copiando los directorios vacios
					rsync -a -p -m --include="*.$i" --include="*/" --exclude="*" $1 $2
					#Se comprueba que rsync no ha dado error en su ejecución
					if [ $? -gt 0  ]
						then
							echo "Error $? -> no se ha podido copiar un archivo"
							CODIGOERROR=1
					fi
					#En cada iteracion contamos los ficheros que tienen la extension indicada y se lo sumamos a la variable que nos mostrara el total de archivos copiados
					NUMFICHEROS=$((NUMFICHEROS + `find "$1" -wholename "$1*.$i" | wc -l`))
				fi
		fi
	done
if [ $NUMFICHEROS == 0 ]
	then
		echo "No se ha copiado archivo alguno debido a que no existen archivos con dichas extensiones"
		exit 2
fi
#Muestra el directorio destino mediante tree
tree $2
echo -e "\nNumero de ficheros copiados = $NUMFICHEROS"
echo "Numero de directorios copiados = $NUMDIRECTORIOS"
exit $CODIGOERROR

