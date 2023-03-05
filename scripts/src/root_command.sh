# echo "# this file is located in 'src/root_command.sh'"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

ip_central="155.210.154.100"
ip=${args[--hostname]}
target=${args[target]}
wake=${args[--wake-up]}
shutdown=${args[--shutdown]}
if [[ $wake ]]; then
    username=${args[--wake-up]}
elif [[ $shutdown ]]; then
    username=${args[--shutdown]}
fi
list=${args[--list]}
users=${args[--users]}
power_on=${args[--wake-up]}
power_off=${args[--shutdown]}

target_list=()

red='\e[0;31m'
green='\e[0;32m'
noc='\e[0m'

check_address () {
    ttl=$(ping -c 1 -W 2 $1 2>&1 | grep -o 'ttl=[0-9]*' | cut -d= -f2)
    if [[ $ttl =~ ^[0-9]+$ ]]; then

        host=$(host $1 2>/dev/null | grep -oE '[^ ]+$' | cut -d'.' -f1)
        if echo $host | grep "NXDOMAIN" > /dev/null 2>&1; then
            host='unknown'
        fi
        
        if [ $ttl -le 64 ]; then
            status="${green}Unix/Linux${noc}"
        elif [ $ttl -le 128 ]; then
            status="${green}Windows${noc}"
        elif [ $ttl -le 254 ]; then
            status="${green}Solaris/AIX${noc}"
        fi
    else
        host="unknown"
        status="${red}DOWN${noc}"
    fi

    echo -e "$host $1 $status"
}

check_users () {
    if ping -c 1 -W 2 $1 > /dev/null 2>&1; then
        ssh -qt a798095@155.210.154.201 "who | cut -f1 -d' ' | sort -u" |
        while read user; do
            echo $1 $user
        done
    fi
}

get_host () {
    host=$(host $1 2>/dev/null | grep -oE '[^ ]+$' | cut -d'.' -f1)
    if echo $host | grep "NXDOMAIN" > /dev/null 2>&1; then
        echo "no se encontro el nombre del host"
        exit 1
    fi
    echo $host
}

if [[ $ip ]]; then
# tener solo en cuenta el hostname
    target_list+=("$ip")
else 
# tener en cuenta el target
    if [ -f $target ]; then
        while IFS= read -r -d $'\n' linea; do
            target_list+=("$linea")
        done < $target
    else 
        echo "Fichero de ips ausente"
        exit 1    
    fi
fi

if [[ $list ]]; then

    for addr in "${target_list[@]}"; do
        if [[ $users ]]; then
            check_users $addr
        else 
            check_address $addr
        fi
    done

elif [[ $power_on ]]; then
    
    for addr in "${target_list[@]}"; do
        # Busqueda del nombre del host
        host=$(get_host $addr)
        echo ssh ${username}@${ip_central} "/usr/local/etc/wake -y ${host}"
        echo -e ${addr} is now ${green}up${noc}
    done

elif [[ $power_off ]]; then

    for addr in "${target_list[@]}"; do
        # Prueba de conexion con el target
        if ! ping -c 1 -W 2 $addr > /dev/null 2>&1; then
            echo "can't connect to: $addr"
            break
        fi
        # Busqueda del nombre del host
        host=$(get_host $addr)

        # comprobar el numero de usuarios conectados a la maquina
        users_connected=$(ssh -qt ${username}@${addr} "who | cut -f1 -d' ' | sort -u")
        num_users=$(echo "$users_connected" | wc -l)
        if [ $num_users -gt 1 ]; then
            echo "La maquina esta siendo usada por mas de un usuario"
            exit 0
        elif ! echo "$users_connected" | grep -qw "$username"; then
            echo "La maquina esta siendo usada por otra persona"
            exit 0
        fi

        # comprobar que no haya maquinas en ejecucion
        vm_running_orig=$(ssh -qt ${username}@${addr} "virsh -c qemu:///system list | grep -v '^$' | tail -n +3")
        vm_running=()

        # crea una lista de los elementos validos de la lista original
        echo "$vm_running_orig" | while read -r -d $'\n' line; do
            if ! [ -z "$line" ]; then
                vm_running+=("$linea")
            fi
        done

        # comprueba si hay maquinas virtuales en ejecucion
        if [ ${#vm_running[@]} -eq 1 ]; then
            echo "Hay ${#vm_running[@]} maquina virtual ejecutandose"
            exit 0
        elif [ ${#vm_running[@]} -gt 1 ]; then
            echo "Hay ${#vm_running[@]} maquinas virtuales ejecutandose"
            exit 0
        fi

        echo ssh ${username}@${ip_central} "/usr/local/etc/shutdown.sh -y ${host}"
        echo -e ${addr} is now ${red}down${noc}
    done

fi