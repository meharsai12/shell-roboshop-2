#!/bin/bash

source ./common.sh
app_name=catalogue
check_root

nodejs_setup

roboshop_user

app_setup
systemd_setup


cp $SCRIPT_DIR/catalogue.service  /etc/systemd/system/catalogue.service  &>>$LOG_FILE
VALIDATE $? "copying catalogueservice"

cp  $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo  &>>$LOG_FILE
VALIDATE $? "copying mongodb repo "


dnf install mongodb-mongosh -y  &>>$LOG_FILE
VALIDATE $? "installing mongodb client"

STATUS=$(mongosh --host mongodb.mehar.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.mehar.fun </app/db/master-data.js  &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB" 
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

print_time
