# echo "# this file is located in 'src/scan_command.sh'"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

# ----- CONFIG ---------
account="a798095"
# ----- COLORS ---------
green='\e[0;32m'
red='\e[0;31m'
noc='\e[0m'
# ----- FLAGS ----------
flag_all=${args[--all]}
flag_users=${args[--users]}
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
        echo "File $flag_file does not exist"
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

check_status() {
    local addr=$1
    ttl=$(ping -c 1 -W 2 $addr 2>&1 | grep -o 'ttl=[0-9]*' | cut -d= -f2)
    if [[ $ttl =~ ^[0-9]+$ ]]; then

        host=$(get_host $addr)
        
        if [ $ttl -le 64 ]; then
            status="${green}Unix/Linux${noc}"
        elif [ $ttl -le 128 ]; then
            status="${green}Windows${noc}"
        elif [ $ttl -le 254 ]; then
            status="${green}Solaris/AIX${noc}"
        fi

    else
        host="unknown   "
        status="${red}DOWN${noc}"
    fi

    echo -e "$host $addr $status"
}


# ----------------------------------------
#                 SCANNING                
# ----------------------------------------

for addr in "${target_list[@]}"; do
    status=$(check_status $addr)

    if [[ $flag_users ]]; then

        if echo $status | grep -q 'DOWN'; then continue;
        else 
            ssh_output=$(ssh -qt -o ConnectTimeout=2 -o StrictHostKeyChecking=no $account@$addr "who | cut -f1 -d' ' | sort -u")
            for user in $ssh_output; do
                echo -e "$status $user"
            done
        fi
        
    else
        echo -e $status
    fi
done