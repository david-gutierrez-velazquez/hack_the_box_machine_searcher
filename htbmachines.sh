#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${greenColour}[+]${endColour}${blueColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${blueColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${blueColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${blueColour} Mostrar la ip de la maquina${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${blueColour} Mostrar el link de resolucion de la maquina${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${blueColour} Listar las maquinas por nivel de dificultad${endColour}"
  echo -e "\t${purpleColour}a)${endColour}${blueColour} Listar todas las maquinas ${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${blueColour} Listar todas las maquinas resueltas por sistema operativo${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${blueColour} Mostrar el panel de ayuda${endColour}\n"

}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Comenzamos con las actualizaciones...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Los archivos se han descargado${endColour}"
  else
     tput civis
     echo -e "\n${greenColour}[+]${endColour}${blueColour} Comprobando si hay actualizaciones pendientes...${endColour}"
     curl -s $main_url > bundle_temp.js
     js-beautify bundle_temp.js | sponge bundle_temp.js
     md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
     md5_original_value=$(md5sum bundle.js | awk '{print $1}')

     if [ "md5_temp_value" == "$md5_original_value" ]; then
       echo -e "\n${greenColour}[+]${endColour}${blueColour} No se han detectado actualizaciones${endColour}"
       rm bundle_temp.js
     else
       echo -e "\n${greenColour}[+]${endColour}${blueColour} Hay actualizaciones disponibles${endColour}"
       sleep 1

     rm bundle.js && mv bundle_temp.js bundle.js

     echo -e "\n${greenColour}[+]${endColour}${blueColour} Los archivos se han actualizado${endColour}"
     fi

     tput cnorm

   fi
}


function searchMachine(){
  machineName="$1"

  machine_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -v -e id -e sku -e resuelta | tr -d '"' | tr -d ',' | awk '{$1=$1; print}')"

  if [ "$machine_checker" ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Listando las propiedades de la maquina seleccionada...${endColour}${grayColour} $machinaName${endColour}\n"
    sleep 1
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -v -e id -e sku -e resuelta | tr -d '"' | tr -d ',' | awk '{$1=$1; print}'
  else
    sleep 1
    echo -e "\n${greenColour}[!]${endColour}${blueColour} La maquina no existe, porfavor prueba de nuevo.${endColour}"
  fi
}

function searchIP(){
  ipSearch="$1"

  ipchecker="$(cat bundle.js | awk "/name: \"$ipSearch\"/,/resuelta:/" | grep -E "ip:" | tr -d "," | tr -d "ip:" | tr -d '"' | awk 'NF{print $NF}')"

  if [ "$ipchecker" ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Listando la ip de la maquina seleccionada...${endColour}\n"
    sleep 1
    cat bundle.js | awk "/name: \"$ipSearch\"/,/resuelta:/" | grep -E "ip:" | tr -d "," | tr -d "ip:" | tr -d '"' | awk 'NF {print $NF}'
  else
    sleep 1
    echo -e "\n${greenColour}[!]${endColour}${blueColour} La maquina no exite, porfavor prueba de nuevo.${endColour}"
  fi
}

function searchlink(){
  link="$1"

  linksearch="$(cat bundle.js | awk "/name: \"$link\"/,/resuelta:/" | grep -E "youtube" | tr -d "," | tr -d "ip:" | tr -d '"' | awk 'NF{print $NF}')"

  if [ "$linksearch" ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Listando el link de youtube de la maquina seleccionada...${endColour}\n"
    sleep 1
    cat bundle.js | awk "/name: \"$link\"/,/resuelta:/" | grep -E "youtube" | tr -d "," | tr -d "ip:" | tr -d '"' |  awk 'NF{print $NF}'
  else
    sleep 1
    echo -e "\n${greenColour}[!]${endColour}${blueColour} La maquina no existe, porfavor prueba de nuevo.${endColour}"
  fi
}

function difficulty(){
  leveldiff="$1"

  searchdiff="$(cat bundle.js | grep "dificultad: \"$leveldiff\"" -B 6 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column)"

  if [ "$searchdiff" ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Listando las maquinas con dificultad $leveldiff...${endColour}\n"
    sleep 1
    cat bundle.js | grep "dificultad: \"$leveldiff\"" -B 6 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column
  else
    sleep 1
    echo -e "\n${greenColour}[!]${endColour}${blueColour} El nivel $leveldiff no existe, porfavor prueba de nuevo.${endColour}"
  fi
}

function sisopfilter(){
  so="$1"

  sisop="$(cat bundle.js | grep "so: \"$so\"" -B 6 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column)"

  if [ "$sisop" ]; then
    echo -e "\n${greenColour}[+]${endColour}${blueColour} Listando las maquinas con sistema operativo $so...${endColour}\n"
    sleep 1
    cat bundle.js | grep "so: \"$so\"" -B 6 | grep name | tr -d '"' | tr -d "," | awk 'NF{print $NF}' | column
  else
    sleep 1
    echo -e "\n${greenColour}[!]${endColour}${blueColour} El sistema operativo no exite, porfavor intentelo de nuevo.${endColour}\n"
  fi
}

function listmachines(){
  echo -e "\n${greenColour}[+]${endColour} ${blueColour} Estos son los nombres de todas las maquinas:${endColour}\n"
  sleep 1
  cat bundle.js | grep "name: \"" | tail -n +8 | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | tr -d '/' | column
}


# Indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:s:ah" arg; do
  case $arg in
   m) machineName=$OPTARG; let parameter_counter+=1;;
   u) let parameter_counter+=2;;
   i) ipSearch=$OPTARG; let parameter_counter+=3;;
   y) link=$OPTARG; let parameter_counter+=4;;
   d) leveldiff=$OPTARG; let parameter_counter+=5;;
   a) let parameter_counter+=6;;
   s) so=$OPTARG; let parameter_counter+=7;;
   h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipSearch
elif [ $parameter_counter -eq 4 ]; then
  searchlink $link
elif [ $parameter_counter -eq 5 ]; then
  difficulty $leveldiff
elif [ $parameter_counter -eq 6 ]; then
  listmachines
elif [ $parameter_counter -eq 7 ]; then
  sisopfilter $so
else
  helpPanel
fi
