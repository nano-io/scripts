
#!/bin/bash
#
# Sample for getting temp session token from AWS STS
#
# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#
# Once the temp token is obtained, you'll need to feed the following environment
# variables to the aws-cli:
#
# export AWS_ACCESS_KEY_ID='KEY'
# export AWS_SECRET_ACCESS_KEY='SECRET'
# export AWS_SESSION_TOKEN='TOKEN'

AWS_CLI=`which aws`

if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed!"
  exit 1
fi

$AWS_CLI --version

# 1 or 2 args ok
if [[ $# -ne 1 && $# -ne 2 ]]; then
  echo "Usage: $0 <token> [profile]"
  echo "Where:"
  echo "   token = Code from virtual MFA device"
  echo "   profile = aws-cli profile usually in $HOME/.aws/config. Optional, default is 'default'."
  exit 2
fi

#echo "Reading config..."
#if [ -r ~/mfa.cfg ]; then
#  . ~/mfa.cfg
#else
#  echo "No config found.  Please create your mfa.cfg.  See README.txt for more info."
#  exit 2
#fi

MFA_TOKEN_CODE=$1
AWS_CLI_PROFILE=${2:-default}
#ARN_OF_MFA=${!AWS_CLI_PROFILE}
ARN_OF_MFA="arn:aws:iam::211161777205:mfa/mark"

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $ARN_OF_MFA"
echo "MFA Token Code: $MFA_TOKEN_CODE"

echo "Your Temporary Credentials:"
aws --profile $AWS_CLI_PROFILE sts get-session-token \
  --duration 129600 \
  --serial-number $ARN_OF_MFA --token-code $MFA_TOKEN_CODE --output text \
  | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACC
