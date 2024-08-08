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
    echo -e "\n\n${redColour}[!] Saliendo ...${endColour}\n"
    exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}${purpleColour}$0${endColour}\n"
    echo -e "\t${yellowColour}-m)${endColour}${blueColour} Dinero con el que se desea jugar${endColour}"
    echo -e "\t${yellowColour}-t)${endColour}${blueColour} Técnica a utilizar${endColour}${purpleColour} (martingala/inverseLabrouchere/dAlembert)${endColour}"
    exit 1
}

function restarBordes(){
    unset my_sequence[0]
    unset my_sequence[-1] 2>/dev/null

    if [ ${#my_sequence[@]} -eq 0 ]; then
        my_sequence=(1 2 3 4)
    fi
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

    echo -e "${blueColour}[+]${endColour}${yellowColour} Vamos a jugar con una cantidad inicial de${endColour}${greenColour} $initial_bet€${endColour} a${purpleColour} $par_impar${endColour}."

    intermedio=$initial_bet
    max_money=$initial_bet
    play_counter=1

    while true; do
        if [ "$initial_bet" -gt "$money" ]; then
            echo -e "${redColour}[!] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas.${endColour}"
            echo -e "${redColour}[!] Has perdido. No tienes suficiente dinero para cubrir la apuesta, se baja la apuesta.${endColour}"
            break
        fi

        money=$(($money - $initial_bet))

        random_number=$(($RANDOM % 37))
        echo -e "\n${blueColour}[+]${endColour}${yellowColour} Ha salido el número ${endColour}${greenColour}$random_number${endColour}"

        if [ $(($random_number % 2)) -eq 0 ]; then
            if [ $random_number -eq 0 ]; then
                echo -e "${redColour}[+] Ha salido el 0, por lo que gana la banca.${endColour}"
                initial_bet=$(($initial_bet * 2))
            else
                echo -e "${blueColour}[+] El número es par${endColour}"
                if [ "$par_impar" == "impar" ]; then
                    initial_bet=$(($initial_bet * 2))
                else
                    money=$(($money + ($initial_bet * 2)))
                    initial_bet=$intermedio
                fi
            fi
        else
            echo -e "${blueColour}[+] El número es impar${endColour}"
            if [ "$par_impar" == "par" ]; then
                initial_bet=$(($initial_bet * 2))
            else
                money=$(($money + ($initial_bet * 2)))
                initial_bet=$intermedio
            fi
        fi

        echo -e "${blueColour}[+]${endColour}${yellowColour} Tu dinero es${endColour} ${greenColour}$money€${endColour}, ${yellowColour}la apuesta inicial es${endColour} ${greenColour}$initial_bet€${endColour}."

        if [ "$money" -le 0 ]; then
            echo -e "${redColour}[!] Te has quedado sin dinero.${endColour}"
            echo -e "${redColour}[!] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas.${endColour}"
            echo -e "${redColour}[!] Tu máximo dinero alcanzado ha sido: ${greenColour}$max_money€${endColour}.${endColour}"
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

    tput civis
    while true; do
        bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
        let money-=$bet

        echo -e "\n\t${blueColour}[+]${endColour}${yellowColour} Comenzamos con la secuencia${endColour}${turquoiseColour} [${my_sequence[@]}]${endColour}"
        echo -e "\n\t${blueColour}[+]${endColour}${yellowColour} Invertimos${endColour}${turquoiseColour} $bet${endColour}"
        echo -e "\n\t${blueColour}[+]${endColour}${yellowColour} Tenemos${endColour}${greenColour} $money€${endColour}"

        random_number=$(($RANDOM % 37))
        echo -e "\n${blueColour}[+]${endColour}${yellowColour} Ha salido el número${endColour}${greenColour} $random_number${endColour}."

        if [ "$par_impar" == "par" ]; then
            if [ "$random_number" -eq 0 ]; then
                echo -e "${redColour}[+] El número es $random_number, ¡Pierdes!${endColour}"
                restarBordes
            elif [ $(($random_number % 2)) -eq 0 ]; then
                echo -e "${blueColour}[+] El número es par,${endColour}${greenColour} ¡Ganas!${endColour}"
                reward=$(($bet * 2))
                let money+=$reward
                my_sequence+=($bet)
            else
                echo -e "${redColour}[!] El número es impar,${endColour}${redColour} ¡Pierdes!${endColour}"
                restarBordes
            fi
        else
            if [ "$random_number" -eq 0 ]; then
                echo -e "${redColour}[+] El número es $random_number, ¡Pierdes!${endColour}"
                restarBordes
            elif [ $(($random_number % 2)) -eq 0 ]; then
                echo -e "${redColour}[!] El número es par,${endColour}${redColour} ¡Pierdes!${endColour}"
                restarBordes
            else
                echo -e "${blueColour}[+] El número es impar,${endColour}${greenColour} ¡Ganas!${endColour}"
                reward=$(($bet * 2))
                let money+=$reward
                my_sequence+=($bet)
            fi
        fi

        echo -e "${blueColour}[+]${endColour}${yellowColour} Nuestra nueva secuencia es${endColour}${turquoiseColour} [${my_sequence[@]}]${endColour}."
        echo -e "${blueColour}[+]${endColour}${yellowColour} Tienes${endColour}${greenColour} $money€${endColour}."

        if [ $money -le 0 ]; then
            echo -e "${redColour}[!] Te has quedado sin dinero.${endColour}"
            break
        fi

        sleep 1
    done
    tput cnorm
}

function dAlembert(){
    echo -e "\n${blueColour}[+]${endColour}${yellowColour} Dinero actual: ${endColour}${greenColour}$money€${endColour}"
    echo -ne "${blueColour}[+]${endColour}${yellowColour} ¿Cuánto dinero tienes pensado apostar? ->${endColour}" && read base_bet
    echo -ne "${blueColour}[+]${endColour}${yellowColour} ¿A qué deseas apostar continuamente? (par/impar) ->${endColour}" && read par_impar

    if [[ ! "$base_bet" =~ ^[0-9]+$ ]] || [[ "$base_bet" -le 0 ]]; then
        echo -e "${redColour}[!] La apuesta base debe ser un número positivo.${endColour}"
        exit 1
    fi

    if [[ "$par_impar" != "par" && "$par_impar" != "impar" ]]; then
        echo -e "${redColour}[!] La apuesta debe ser 'par' o 'impar'.${endColour}"
        exit 1
    fi

    echo -e "${blueColour}[+]${endColour}${yellowColour} Vamos a jugar con una apuesta base de${endColour}${greenColour} $base_bet€${endColour} a${purpleColour} $par_impar${endColour}."

    bet=$base_bet
    max_money=$money
    play_counter=1

    while true; do
        if [ "$bet" -gt "$money" ]; then
            echo -e "${redColour}[!] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas.${endColour}"
            echo -e "${redColour}[!] No tienes suficiente dinero para cubrir la apuesta.${endColour}"
            break
        fi

        money=$(($money - $bet))

        random_number=$(($RANDOM % 37))
        echo -e "\n${blueColour}[+]${endColour}${yellowColour} Ha salido el número ${endColour}${greenColour}$random_number${endColour}"

        if [ $(($random_number % 2)) -eq 0 ]; then
            if [ $random_number -eq 0 ]; then
                echo -e "${redColour}[+] Ha salido el 0, por lo que gana la banca.${endColour}"
                bet=$(($bet + 1))
            else
                echo -e "${blueColour}[+] El número es par${endColour}"
                if [ "$par_impar" == "impar" ]; then
                    bet=$(($bet + 1))
                else
                    money=$(($money + ($bet * 2)))
                    bet=$(($bet - 1))
                    if [ $bet -lt $base_bet ]; then
                        bet=$base_bet
                    fi
                fi
            fi
        else
            echo -e "${blueColour}[+] El número es impar${endColour}"
            if [ "$par_impar" == "par" ]; then
                bet=$(($bet + 1))
            else
                money=$(($money + ($bet * 2)))
                bet=$(($bet - 1))
                if [ $bet -lt $base_bet ]; then
                    bet=$base_bet
                fi
            fi
        fi

        echo -e "${blueColour}[+]${endColour}${yellowColour} Tu dinero es${endColour} ${greenColour}$money€${endColour}, ${yellowColour}la apuesta actual es${endColour} ${greenColour}$bet€${endColour}."

        if [ "$money" -le 0 ]; then
            echo -e "${redColour}[!] Te has quedado sin dinero.${endColour}"
            echo -e "${redColour}[!] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas.${endColour}"
            echo -e "${redColour}[!] Tu máximo dinero alcanzado ha sido: ${greenColour}$max_money€${endColour}.${endColour}"
            break
        fi

        let play_counter+=1

        if [ $money -gt $max_money ]; then
            max_money=$money
        fi
    done
}

while getopts "m:t:" arg; do
    case $arg in
        m) money=$OPTARG ;;
        t) technique=$OPTARG ;;
        *) helpPanel ;;
    esac
done

if [ $money ] && [ $technique ]; then
    if [ "$technique" == "martingala" ]; then
        martingala
    elif [ "$technique" == "inverseLabrouchere" ]; then
        inverseLabrouchere
    elif [ "$technique" == "dAlembert" ]; then
        dAlembert
    else
        echo -e "${redColour}[!] La técnica introducida no existe.${endColour}"
        helpPanel
    fi
else
    helpPanel
fi
