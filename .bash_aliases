set-title() {
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

setAwsKeys() {
    if [ -r ~/bin/aws-get-keys.sh ]; then
        aws-get-keys.sh $1 $2
        # should test for profile here too
        source ~/.aws/aws_keys
        echo "Your AWS credentials have been updated."
        rm ~/.aws/aws_keys 
    else
      echo "aws-get-token.sh script not found.  Please place script in your bin folder."
    fi
}
alias aws-keys=setAwsKeys
alias fv='tr '\''\01'\'' '\''|'\'' < '
