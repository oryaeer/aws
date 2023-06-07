#!/bin/bash

action="$1"

if [[ -z $action ]]; then
  echo "Please provide an action parameter: --stop, --start, or --destroy."
  exit 1
fi

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

    if [[ -z $instance_ids ]]; then
      echo "No stopped EC2 instances found."
      exit 0
    fi

    for instance_id in $instance_ids; do
      echo "Starting instance: $instance_id"
      aws ec2 start-instances --instance-ids "$instance_id"
    done

    echo "All stopped EC2 instances have been started."
    ;;

  --destroy)
    read -p "Are you sure you want to destroy (terminate) all EC2 instances? (y/n) " confirm

    if [[ $confirm == [yY] ]]; then
      echo "Terminating all EC2 instances."
      instance_ids=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)

      if [[ -z $instance_ids ]]; then
        echo "No EC2 instances found."
        exit 0
      fi

      for instance_id in $instance_ids; do
        echo "Terminating instance: $instance_id"
        aws ec2 terminate-instances --instance-ids "$instance_id"
      done

      echo "All EC2 instances have been terminated."
    else
      echo "Termination canceled. No EC2 instances were destroyed."
    fi
    ;;

  *)
    echo "Invalid action parameter. Please use --stop, --start, or --destroy."
    exit 1
    ;;
esac

