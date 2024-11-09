#!/bin/bash
cd /mnt/D/DevOps/rs.school/aws-devops
export PRIVATE_INSTANCE_IP=$(terraform output -raw private_instance_ip) && export BASTION_HOST_IP=$(terraform output -raw nat_instance_ip)
ssh-keygen -f '/home/alex/.ssh/known_hosts' -R $PRIVATE_INSTANCE_IP
ssh-keygen -f '/home/alex/.ssh/known_hosts' -R $BASTION_HOST_IP
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyJump=ec2-user@$BASTION_HOST_IP ubuntu@$PRIVATE_INSTANCE_IP:/etc/rancher/k3s/k3s.yaml ~/.config/Lens/kubeconfigs/k3s_aws
echo "K3s config copied successfully"
ssh -L 6443:$PRIVATE_INSTANCE_IP:6443 ec2-user@$BASTION_HOST_IP
