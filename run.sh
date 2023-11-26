#!/bin/bash

source .env

# delete old git files 
rm -rf .git
sudo chmod +x *.sh

# check Docker installation
docker_check=$(whereis docker)
dockercompose_check=$(whereis compose)
if [[ "$docker_check" == *"/etc/docker"* && 
    "$dockercompose_check" == *"/usr/bin/compose"* ]]; then
    printf "Docker is already installed...\n"
else 
    printf "Installing Docker...\n"
    bash docker.sh
fi

# check if project services are running and clean them
running_containers=$(docker ps)
if [[ "$running_containers" == *"api_service"* ]]; then
    printf "stopping container api_service..."
    docker stop api_service 
    docker rm api_service -f
fi

if [[ "$running_containers" == *"db_service"* ]]; then
    printf "stopping container db_service..."
    docker stop db_service
    docker rm db_service -f
fi

read -p "What is the Project's Name? " project_name

sudo chown -R $USER *

# changes DB_NAME in .env file accordingly to project's name
db_name="${project_name}_dev" # name is like: project_name_dev
sed -i "s/DB_NAME=.*/DB_NAME=$db_name/" .env

# change DB_HOST in .env file and hostname in config/dev.exs 
# accordingly to postgres service name in docker-compose.yaml (defined as db_service)
db_host="db_service" # MUST be the same name defined in database service name in docker-compose.yaml
sed -i "s/DB_HOST=.*/DB_HOST=$db_host/" .env

# parent path
parent_path=${PWD%/*}/$1

# new folder name accordingly to project name
new_project_path="${parent_path}${project_name}"

# rename current folder with project's name 
sudo mv $(pwd) $new_project_path

sudo mkdir scripts
mkdir apps
sudo mv dev.sh scripts/

virtualenv .venv --python=3.10.12
source .venv/bin/activate
pip install django djangorestframework djangorestframework-simplejwt django-filter psycopg2 python-decouple
pip freeze > requirements.txt
django-admin startproject core .
sudo mv settings.py core

docker compose run api_service pip install -r requirements.txt

# give owner files to user
sudo chown -R $USER *

rm run.sh
rm docker.sh
git init

function check_node_install() {
    node_check=$(whereis node)

    if [[ "$node_check" != *"node"* ]]; then 
        printf "Husky, Commitlint and Commitizen have unmet dependencies: Node.\n"
        read -p "Do you want to install Node? [Y/n] " answer
        answer=${answer:-Y}

        if [[ "$answer" == "Y" ]]; then
            bash node_installer.sh
        fi
    fi
}

function install_husky_commitlint_commitizen() {
    check_node_install

    if [[ "$node_check" == *"node"* ]]; then  
        npm init

        # install husky, commitlint and commitizen
        npm install -g husky @commitlint/{cli,config-conventional} commitizen --save-dev --save-exact

        # add rules to commitlint
        echo "module.exports = { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js

        # makes your repo "commitizen friendly"
        commitizen init cz-conventional-changelog --save-dev --save-exact

        # run husky and create commitlint hook for commit-msg
        npx husky install
        npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'

        sudo chown -R $USER .*
    fi
}

printf "\n"
read -p "Do you want to set Husky, Commitlint and Commitizen on $project_name project? [Y/n] " answer
answer=${answer:-Y}

if [[ "$answer" == "Y" ]]; then
    install_husky_commitlint_commitizen
fi

rm node_installer.sh
rm git_installer.sh

docker stop db_service
docker rm db_service -f

# update current shell references
exec $SHELL
