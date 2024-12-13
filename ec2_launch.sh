# Launch an EC2 instance
function launch_ec2(){
    echo "Launching EC2 instance..."

    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --count 1 \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --subnet-id "$SUBNET_ID" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key="$TAG_KEY",Value="$TAG_VALUE"}]" \
    --query 'Instances[0].InstanceId' \
    --output 2>/tmp/aws_error.log)

    # Check the instance launch status
    if [ -z "$INSTANCE_ID" ]; then 
        echo "Error: Failed to launch EC2 instance."
        echo "Details: $(cat /tmp/aws_error.log)"
        return 1
    fi 
       
    echo "EC2 instance launched successfully with ID: "$INSTANCE_ID" "

    # call function 
    launch_ec2