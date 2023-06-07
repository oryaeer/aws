#!/bin/bash

action="$1"

case $action in
  --stop)
    echo "Stopping all running EC2 instances."
    instance_ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)

    if [[ -z $instance_ids ]]; then
      echo "No running EC2 instances found."
      exit 0
    fi

    for instance_id in $instance_ids; do
      echo "Stopping instance: $instance_id"
      aws ec2 stop-instances --instance-ids "$instance_id"
    done

    echo "All running EC2 instances have been stopped."
    ;;
  
  --start)
    echo "Starting all stopped EC2 instances."
    instance_ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --query "Reservations[*].Instances[*].InstanceId" --output text)

    for instance_id in $instance_ids; do
      echo "Starting instance: $instance_id"
      aws ec2 start-instances --instance-ids "$instance_id"
    done

    echo "All stopped EC2 instances have been started."
    ;;
    
  --destroy)
    echo "Terminating all EC2 instances."
    instance_ids=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)

    for instance_id in $instance_ids; do
      echo "Terminating instance: $instance_id"
      aws ec2 terminate-instances --instance-ids "$instance_id"
    done

    echo "All EC2 instances have been terminated."
    ;;
    
  *)
    echo "Invalid action. Please specify --stop, --start, or --destroy."
    exit 1
    ;;
  
  --createami)
  

  # Launch EC2 instance
  echo "Launching EC2 instance..."
  instance_id=$(aws ec2 run-instances --image-id "ami-0715c1897453cabd1" --instance-type "t2.micro" --key-name "oryaeer" --subnet-id "subnet-099271a2111dd07db" --security-group-ids "sg-0a24d62166110b86e" --count "1" --output text --query 'Instances[0].InstanceId')
  echo "Instance launched with ID: $instance_id"

  # Wait for instance to be running
  echo "Waiting for the instance to be running..."
  aws ec2 wait instance-running --instance-ids $instance_id
  echo "Instance is now running"
  
  sudo git clone https://github.com/oryaeer/flask.git /home/ec2-user
  aws ec2 create-image --instance-id $instance_id --name "MyAMI" --description "My custom AMI"
  echo "created ami"
  ;;
  


esac

