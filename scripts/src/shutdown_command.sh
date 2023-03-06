# echo "# this file is located in 'src/shutdown_command.sh'"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

# ----- CONFIG ---------
account="a798095"
central="155.210.154.100"
# ----- FLAGS ----------
flag_all=${args[--all]}
flag_file=${args[--file]}
# ----- ARGS -----------
hostname=${args[hostname]}
# ----- Global ---------
target_list=()  # Lista de direcciones ip
# ----------------------

if [[ $flag_file ]]; then
    if [ -f $flag_file ]; then
        while read -r -d $'\n' linea; do
            target_list+=("$linea")
        done < $flag_file
    else 
        echo "No existe"
        exit 1
    fi
else
    if [[ $flag_all ]]; then
        # Rango de ips del lab102
        for i in {191..210}; do
            target_list+=("155.210.154.${i}")
        done
    else 
        target_list=$hostname
    fi
fi

get_host () {
    local addr=$1
    host=$(host $addr 2>/dev/null | grep -oE '[^ ]+$' | cut -d'.' -f1)
    if echo $host | grep "NXDOMAIN" > /dev/null 2>&1; then
        host='unknown'
    fi
    echo $host
}

# ----------------------------------------
#               SHUTING DOWN              
# ----------------------------------------

for addr in "${target_list[@]}"; do
    # Prueba de conexion con el target
    if ! ping -c 1 -W 2 $addr >/dev/null 2>&1; then
        echo "can't connect to: $addr"
        break
    fi
    set +x
    # comprobar el numero de usuarios conectados a la maquina
    users_connected=$(ssh -qt -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${addr} "who | cut -f1 -d' ' | sort -u")
    num_users=$(echo "$users_connected" | wc -l)

    if [ $num_users -gt 1 ]; then
        echo "La maquina esta siendo usada por mas de un usuario"
        break
    fi

    # obtiene las maquinas virtuales que se estan ejecutando en la maquina $addr
    vm_running=$(echo $(ssh -qt -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${addr} "virsh -c qemu:///system list | tail -n +3 | tr -s ' ' | cut -f3 -d' ' | grep -v '^$' | wc -l") | tr -d '\r')

    # comprueba si hay maquinas virtuales en ejecucion
    if [ $vm_running -eq 1 ]; then
        echo "Hay $vm_running maquina virtual ejecutandose"
        break
    elif [ $vm_running -gt 1 ]; then
        echo "Hay $vm_running maquinas virtuales ejecutandose"
        break
    fi

    # # Busqueda del nombre del host
    host=$(get_host $addr)

    echo ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${central} "/usr/local/etc/shutdown.sh -y ${host}"
    echo -e "$host ${addr} is now ${red}down${noc}"
done