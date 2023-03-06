# echo "# this file is located in 'src/wake_command.sh'"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

# ----- CONFIG ---------
account="a798095"
central="155.210.154.100"
# ----- COLORS ---------
green='\e[0;32m'
noc='\e[0m'
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
#               POWERING UP              
# ----------------------------------------

for addr in "${target_list[@]}"; do
    if ping -c 1 -W 2 $addr >/dev/null 2>&1; then
        # Busqueda del nombre del host
        host=$(get_host $addr)
        echo ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${central} "/usr/local/etc/wake -y ${host}"
        echo -e "${host} ${addr} is now ${green}up${noc}"
    fi
done