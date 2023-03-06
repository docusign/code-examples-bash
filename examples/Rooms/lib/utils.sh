function GetRoleId()
{

    index=-1
    adminFound=false
    eval "arrRoles=($1)"
    element=$2
    arrRoleIds=($3)

    for i in "${!arrRoles[@]}";
    do
        if [[ "${arrRoles[$i]}" = "${element}" ]];
        then
            index=$i
            adminFound=true
            break
        fi
    done

    if [ "$adminFound" == true ]; then
        roleId=${arrRoleIds[$index]}
        echo $roleId  
    # else
    #     workflowId=false
    #     echo $roleId
    fi
}

export -f GetRoleId
