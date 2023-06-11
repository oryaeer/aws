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
    
  
  --createami)
  

    # Launch EC2 instance
    # Launch EC2 instance
    echo "creating instance..."
    instance_id=$(aws ec2 run-instances --image-id "ami-0715c1897453cabd1" --instance-type "t2.micro" --key-name "oryaeer" --security-group-ids "launch-wizard-1" --subnet-id "subnet-099271a2111dd07db" --security-group-ids "sg-0a24d62166110b86e" --count "1" --output text --query 'Instances[0].InstanceId' --user-data '#!/bin/bash
    sudo yum update -y
    sudo yum install python3 python3-pip python3-devel -y
    sudo pip3 install flask
    sudo pip install gunicorn -y
    sudo yum install git -y
    sleep 10
    

    sudo git clone https://github.com/oryaeer/flask.git /home/ec2-user/Git')

    sleep 45
    sudo echo -e "[Unit]\nDescription=Flask Web Application\nAfter=network.target\n\n[Service]\nUser=ec2-user\nWorkingDirectory=/home/ec2-user/Git/bitcoinproject\nExecStart=gunicorn --bind 0.0.0.0:5000 app:app &\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/flaskapp.service
    sudo systemctl enable flaskapp
    sudo systemctl start flaskapp

  



    
    echo "Instance launched with ID: $instance_id"

    # Wait for instance to be running
    echo "Waiting for the instance to be running..."
    aws ec2 wait instance-running --instance-ids $instance_id
    echo "Instance is now running"

    




    # Create AMI
    #echo "Creating AMI..."
    #ami_id=$(aws ec2 create-image --instance-id $instance_id --name "MyAMI" --description "My custom AMI" --output text --query 'ImageId')
    #echo "AMI created with ID: $ami_id"

    # Wait for AMI to become available
    #echo "Waiting for AMI to become available..."
    #aws ec2 wait image-available --image-ids $ami_id
    #echo "AMI is now available"

    
    #echo "created, now terminating the instance"
    
    #aws ec2 terminate-instances --instance-ids $instance_id
    #echo "done!"

    ;;
  
 *)
    echo "Invalid action. Please specify --stop,--createami, --start, or --destroy."
    exit 1

esac

