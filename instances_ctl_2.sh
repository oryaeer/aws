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
esac

