#!/bin/bash

USERID=$(id -u)

R="\e[31m"  #red colour
G="\e[32m"  #green colour
Y="\e[33m"  #yellow colour
N="\e[0m"   #no colour

LOGS_FOLDER="/var/logs/roshop-logs"
SCRIPT_NAME=$(echo $0  | cut -d "." -f1 ) 
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)


mkdir -p $LOGS_FOLDER    # if we add -p if we run n times ifd folder ewxistis no creation if not it will create 

 echo "Script started  Executing at time ::  $(date)"

check_root(){

    if [ $USERID -ne 0 ]
 then 
  echo  -e " You don't have root access ,  $R Please run the script with root access $N "
  exit 1
 else

  echo -e " You have root access $G you can perform actions $N"

  fi
}


VALIDATE(){
    if [ $1 -eq 0 ]
    then 
    echo  -e "$2  is :: ... $G  success  $N"
    else
    echo -e  "$2 .. ::  $R is failure  $N  "
    exit 1

    fi
}


roboshop_user(){

    id roboshop
        if [ $? -ne 0 ]
        then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
        VALIDATE $? "Roboshop system user creation"
        else
        echo -e  "The  user is already existed ..  $G SKIPPING $N  "
        fi
}

nodejs_setup(){
    dnf module disable nodejs -y     &>>$LOG_FILE
    VALIDATE $? "disabling default nodejs"

    dnf module enable nodejs:20 -y   &>>$LOG_FILE
    VALIDATE $? "enabling nodejs-20"

    dnf install nodejs -y   &>>$LOG_FILE
    VALIDATE $? "installing nodejs"

    npm install   &>>$LOG_FILE
        VALIDATE $? "installing dependencies"
}

app_setup(){
        mkdir -p  /app  
        VALIDATE $? "Creating app directory"

        curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
        VALIDATE $? "downloading the $app_name zip file to temp folder"

        rm -rf /app/*     &>>$LOG_FILE
        cd /app      &>>$LOG_FILE
        VALIDATE $? "Navigating to app folder"
        
        unzip /tmp/$app_name.zip  &>>$LOG_FILE
        VALIDATE $? "Unzipping the catalogue zip file here"

        

}

systemd_setup(){
        systemctl daemon-reload   &>>$LOG_FILE
    VALIDATE $? "$app_name daemon-reload"

    systemctl enable $app_name   &>>$LOG_FILE
    VALIDATE $? " enabling $app_name service"

    systemctl start $app_name  &>>$LOG_FILE
    VALIDATE $? "starting $app_name service"
}



print_time(){

    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))

    echo -e "Time taken to execute script is $Y $TOTAL_TIME .... seconds$N"

}