#!/bin/bash

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
    echo -e "\n\n${redColour} [!] Saliendo ...${endColour} \n"
    exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
    echo -e  "\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}${purpleColour}$0${endColour}\n"
    echo -e  "\t${yellowColour}-m)${endColour}${blueColour} Dinero con el que se desea jugar${endColour}"
    echo -e  "\t${yellowColour}-t)${endColour}${blueColour} Técnica a utilizar${endColour}${purpleColour} (martingala/inverseLabrouchere)${endColour}"
    exit 1
}

function martingala(){
    echo -e "\n${blueColour}[+]${endColour}${yellowColour} Dinero actual: ${endColour}${greenColour}$money€${endColour}"
    echo -ne "${blueColour}[+]${endColour}${yellowColour} ¿Cuánto dinero tienes pensado apostar? ->${endColour}" && read initial_bet
    echo -ne "${blueColour}[+]${endColour}${yellowColour} ¿A qué deseas apostar continuamente? (par/impar) ->${endColour}" && read par_impar

    if [[ ! "$initial_bet" =~ ^[0-9]+$ ]] || [[ "$initial_bet" -le 0 ]]; then
        echo -e "${redColour}[!] La apuesta inicial debe ser un número positivo.${endColour}"
        exit 1
    fi

    if [[ "$par_impar" != "par" && "$par_impar" != "impar" ]]; then
        echo -e "${redColour}[!] La apuesta debe ser 'par' o 'impar'.${endColour}"
        exit 1
    fi

    echo -e "${blueColour}[+]${endColour}${yellowColour} Vamos a jugar con una cantidad inicial de${endColour}${greenColour} $initial_bet€${endColour} a${redColour} $par_impar${endColour}."

    intermedio=$initial_bet
	max_money=$initial_bet
	play_counter=1

    while true; do
        if [ "$initial_bet" -gt "$money" ]; then
		echo -e "${redColour}[!] Han habido un total de $play_counter jugadas.${endColour}"
            echo -e "${redColour}[!] Has perdido. No tienes suficiente dinero para cubrir la apuesta, se baja la apuesta.${endColour}"
            break
        fi

        money=$(($money - $initial_bet))

        random_number=$(($RANDOM % 37))
        echo -e "\n[+] Ha salido el número $random_number"

        if [ $(($random_number % 2)) -eq 0 ]; then
            if [ $random_number -eq 0 ]; then
                echo "[+] Ha salido el 0, por lo que gana la banca."
                initial_bet=$(($initial_bet * 2))
            else
                echo "[+] El número es par"
                if [ "$par_impar" == "impar" ]; then
                    initial_bet=$(($initial_bet * 2))
                else
                    money=$(($money + ($initial_bet * 2)))
                    initial_bet=$intermedio
                fi
            fi
        else
            echo "[+] El número es impar"
            if [ "$par_impar" == "par" ]; then
                initial_bet=$(($initial_bet * 2))
            else
                money=$(($money + ($initial_bet * 2)))
                initial_bet=$intermedio
            fi
        fi

        echo "Tu dinero es $money€, la apuesta inicial es $initial_bet€."

        if [ "$money" -le 0 ]; then
            echo -e "${redColour}[!] Te has quedado sin dinero.${endColour}"
            echo -e "${redColour}[!] Han habido un total de $play_counter jugadas.${endColour}"
		echo -e "${redColour}[!] Tu maximo dinero alcanzado ha sido : $max_money .${endColour}"
		break

	fi
		let play_counter+=1

	if [ $money -le $initial_bet ]; then
		initial_bet=$intermedio
	fi

	if [ $money -gt $max_money ]; then 
		max_money=$money
	fi


    done
}




function inverseLabrouchere(){
	echo -e "\n${blueColour}[+]${endColour}${yellowColour} Dinero actual: ${endColour}${greenColour}$money€${endColour}"
    	echo -ne "${blueColour}[+]${endColour}${yellowColour} ¿A qué deseas apostar continuamente? (par/impar) ->${endColour}" && read par_impar

	declare -a my_sequence=(1 2 3 4)

	echo -e "\n\t${blueColour} [+]${endColour}${yellowColour} Comenzamos con la secuencia${endColour}${turquoiseColour}[${my_sequence[@]}]${endColour}"
	bet=$((${my_sequence[0]}+${my_sequence[-1]}))
	money-=$bet
	unset my_sequence[0]
	unset my_sequence[-1]

	my_sequence=(${my_sequence[@]})

	echo -e "\n\t${blueColour} [+]${endColour}${yellowColour} Invertimos${endColour} ${purpleColour}$bet${endColour}${yellowColour} y nuestra secuencia se queda en${endColour}${turquoiseColour} [${my_sequence[@]}] .${endColour}"
	#Quitamos el cursor
	tput civis
	while true; do
		random_number=$(($RANDOM % 37))
		echo -e "\n ${blueColour} [+]${endColour}${yellowColour}Ha salido el numero ${endColour}${greenColour} $random_number ${endColour}."
	if [ "$par_impar" == "par" ]; then

		if [ "$random_number" -eq 0 ]; then

			echo -e "El numero es $random_number, ¡Pierdes!"

		elif [ $(($random_number % 2)) -eq 0 ]; then

			echo -e "${blueColour} [+]${endColour}${yellowColour}El numero es par,${endColour}${greenColour} ¡Ganas!${endColour}"
		else
			echo -e "${redColour}[!]${endColour}${yellowColour} El numero es impar,${endColour}${redColour}Pierdes!${endColour}"
		fi
	fi

	if [ "$par_impar" == "impar" ]; then

                if [ "$random_number" -eq 0 ]; then

                        echo -e "El numero es $random_number, ¡Pierdes!"

                elif [ $(($random_number % 2)) -eq 0 ]; then

                        echo -e "${redColour} [!]${endColour}${yellowColour}El numero es par,${endColour}${redColour} ¡Pierdes!${endColour}"
                else
                        echo -e "${blueColour}[+]${endColour}${yellowColour} El numero es impar,${endColour}${greenColour}¡Ganas!${endColour}"
                fi
        fi



sleep 1
	done
	#Devolvemos el cursor
	tput cnorm

}








    while getopts "m:t:" arg; do
        case $arg in
            m) money=$OPTARG ;;
            t) technique=$OPTARG ;;
            *) helpPanel ;;
        esac
    done


	if [ $money ] && [ $technique ];then
		if [ "$technique" == "martingala" ]; then
			martingala
		elif [ "$technique" == "inverseLabrouchere" ]; then
			inverseLabrouchere
		else
			echo -e "\${redColour}[!] La técnica introducida no existe. ${endColour}"
				helpPanel
		fi
#	else
	fi
