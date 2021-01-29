#!/bin/bash

my_cool_email=borysej90@gmail.com

load_balancer_dim="Name=LoadBalancer,Value=app/practice-4-load-balancer/4547627ce6f76a29"
target_group_dim="Name=TargetGroup,Value=targetgroup/practice-4-target-group/dd7baea246f0d5d2"

topic_arn=$(aws sns create-topic \
            --name healthy_check \
            --output text)

echo "Created SNS Topic"

aws sns subscribe \
        --topic-arn $topic_arn \
        --protocol email \
        --notification-endpoint $my_cool_email

echo "Subscribed to SNS Topic with email $my_cool_email"

aws cloudwatch put-metric-alarm \
            --alarm-name healthy_check \
            --alarm-description "Healthy Alarm" \
            --namespace AWS/ApplicationELB \
            --dimensions $load_balancer_dim $target_group_dim \
            --period 300 \
            --evaluation-periods 1 \
            --threshold 2 \
            --comparison-operator LessThanThreshold \
            --metric-name HealthyHostCount \
            --alarm-actions $topic_arn \
            --statistic Minimum

echo "Created alarm metric"