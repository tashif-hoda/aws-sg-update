#!/bin/bash

##########################################################################################################
# This script is for updating an existing rule in AWS with your latest IP. Use judicially.               #
# Don't go around adding random public IP addresses (or do, I don't know, go crazy!!! (-^_^-) )          #
# Steps to Use:                                                                                          #
# 1. Get security group ID from you AWS console and replace GROUP_ID here                                #
# 2. Get the rule ID and update GROUP_RULE_ID of the rule you want to update with you IP                 #
# 3. Edit the description if you want.                                                                   #
# 4. Change the region to wherever the parent VPC of the security group sits.                            #
# 5. Enjoy the bliss of updating your IP to the security group in the least amount of clicks possible!!! #
##########################################################################################################

#Edit these properties with appropriate values
GROUP_ID=""
GROUP_RULE_ID=""
DESCRIPTION=""
REGION="us-east-1"

#Only edit these if you know what you are doing
IP_PROTOCOL="tcp"
PORT_RANGE=(22 22)
IP_ADDR=$(curl v4.i-p.show)
FULL_IP_ADDR="${IP_ADDR}/32"

INPUT_JSON=$(aws ec2 modify-security-group-rules --generate-cli-skeleton | jq 'del(.SecurityGroupRules[0].SecurityGroupRule.CidrIpv6, .SecurityGroupRules[0].SecurityGroupRule.PrefixListId, .SecurityGroupRules[0].SecurityGroupRule.ReferencedGroupId)' | jq --arg GROUP_ID $GROUP_ID \
	--arg GROUP_RULE_ID $GROUP_RULE_ID \
	--arg IP_PROTOCOL $IP_PROTOCOL \
	--arg FROM_PORT ${PORT_RANGE[0]} \
	--arg TO_PORT ${PORT_RANGE[1]} \
	--arg IP_ADDR_V4 $FULL_IP_ADDR \
	--arg DESCRIPTION $DESCRIPTION \
	'.GroupId |= $GROUP_ID | .SecurityGroupRules[0].SecurityGroupRuleId |= $GROUP_RULE_ID | .SecurityGroupRules[0].SecurityGroupRule.IpProtocol |= $IP_PROTOCOL | .SecurityGroupRules[0].SecurityGroupRule.FromPort |= ($FROM_PORT|tonumber) | .SecurityGroupRules[0].SecurityGroupRule.ToPort |= ($TO_PORT|tonumber) | .SecurityGroupRules[0].SecurityGroupRule.CidrIpv4 |= $IP_ADDR_V4 | .SecurityGroupRules[0].SecurityGroupRule.Description |= $DESCRIPTION')

echo $INPUT_JSON | jq .

aws ec2 modify-security-group-rules --cli-input-json "${INPUT_JSON}" --no-dry-run --region $REGION

