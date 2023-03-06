# echo "# this file is located in 'src/scan_command.sh'"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

# ----- CONFIG ---------
account="a798095"
# ----- FLAGS ----------
flag_all=${args[--all]}
flag_mask=${args[--mask]}
flag_output=${args[--output]}
flag_script=${args[--script-file]}
flag_targets=${args[--flood]}
# ----- ARGS -----------
hostname=${args[hostname]}
command=${args[command]}
# ----- Global ---------
target_list=()  # Lista de direcciones ip
# ----------------------

# Comprueba la existencia de la carpeta output
if [[ $flag_output ]]; then
    if [ -d "output" ]; then
        echo "The output folder exists, deleting its content..."
        rm -rf output
    else
        echo "The output folder does not exist, creating an empty folder..."
        mkdir output
    fi
fi

# Comprueba que el script a ejecutar exista 
if ! [ -f $flag_script ]; then
    echo "File $flag_script does not exist"
    exit 1
fi

# Crea una lista de ips objetivo
if [[ $flag_targets ]]; then
    if [ -f $flag_targets ]; then
        while read -r -d $'\n' linea; do
            target_list+=("$linea")
        done < $flag_targets
    else 
        echo "File $flag_targets does not exist"
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

exec_remote () {
    local addr=$1
    local command=$2

    if [[ $flag_output ]]; then
        ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${addr} ${command} >> "output/$addr"
    else 
        ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${account}@${addr} ${command}
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to execute the command on the remote server: $addr"
    fi
}

apply_mask () {
    local addr=$1
    local filename=$2
    if [[ $mask ]]; then
        exec_remote $addr "chmod ${mask} ${filename}"
    else
        exec_remote $addr "chmod 700 ${filename}"
    fi
}

# ----------------------------------------
#               EXECUTING              
# ----------------------------------------

for addr in "${target_list[@]}"; do
    if ! ping -c 1 -W 2 $addr >/dev/null 2>&1; then
        echo "can't connect to: $addr"
        continue
    fi

    if [[ $flag_script ]]; then
        if scp ${flag_script} ${account}@${addr}:/home/${account}/lab_${flag_script} >/dev/null 2>&1; then
            apply_mask ${addr} "lab_${flag_script}"
            exec_remote ${addr} "./lab_${flag_script}"

        elif scp ${flag_script} ${account}@${addr}:/home/${account}/lab_${flag_script} >/dev/null 2>&1; then
            apply_mask ${addr} "lab_${flag_script}"
            exec_remote ${addr} "./lab_${flag_script}"

        else 
            echo "can't upload the script to: $addr"
            continue
        fi
    else 
        exec_remote ${addr} ${command}
    fi    
done