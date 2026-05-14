#!/bin/bash

source ./common.sh
app_name=mongodb

 check_root

cp  mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo "

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb"

systemctl enable mongod
VALIDATE $? "enabling mongodb"

systemctl start mongod 
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod
VALIDATE $? "restaring  mongodb"

print_time