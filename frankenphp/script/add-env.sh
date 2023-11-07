#!/bin/bash

echo "--Please enter the app name:"
read app
sed -e "s;%APP%;${app};g" frankenphp/template/caddy > frankenphp/caddy/${app}.caddy
echo "> New Caddy configuration created for server ${app}.dev.localhost"

echo "--- Please enter the app local path:"
read -e -i "$HOME/" path
path=$(echo "$path" | sed 's/\/$//')

containers_options=("database" "node" "mail" "redis")
containers_with_volume=("database")

cat frankenphp/template/compose-header.yaml frankenphp/template/compose-php.yaml > ${path}/compose.yaml

relative_path="$(realpath --relative-to="$path" "$(realpath .)")"

#sed -i  ${path}/compose.yaml

for container in "${containers_options[@]}"; do
    echo "--- Do you want a \"$container\" container (press 1 or 2)?"

    select choice in "Yes" "No"; do
        case $choice in
            "Yes")
                cat frankenphp/template/compose-"$container".yaml >> ${path}/compose.yaml
                if [[ " ${containers_with_volume[*]} "  =~ " $container " ]]; then
                    echo "--- Please enter the volume path for this container:"
                    read -e -i "$HOME/" volume
                    relative_volume_path="$(realpath --relative-to="$path" "$volume")"
                    sed -i -e "s;%VOLUME%;${relative_volume_path};g" ${path}/compose.yaml
                fi
                break
                ;;
            "No")
                break
                ;;
            *)
                echo "Invalid choice. Please select '1' or '2'."
                ;;
        esac
    done
done

cat frankenphp/template/compose-footer.yaml >> ${path}/compose.yaml
sed -i -e "s;%APP%;${app};g" -e "s;%RELATIVE_PATH%;${relative_path};g" ${path}/compose.yaml