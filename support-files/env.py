import os
from os.path import exists


class AwsAccessKeyMissing(Exception):
    pass


class AwsSecretKeyMissing(Exception):
    pass


class SshKeyMissing(Exception):
    pass


def aws_access_key():
    aws_access_key = os.environ.get("AWS_ACCESS_KEY")

    if not aws_access_key:
        raise AwsAccessKeyMissing(
            "AWS_ACCESS_KEY env variable is missing, please modify and run the support-files/env_variables.sh script"
        )
    print("AWS_ACCESS_KEY is populated")


def aws_secret_key():
    aws_secret_key = os.environ.get("AWS_SECRET_KEY")

    if not aws_secret_key:
        raise AwsSecretKeyMissing(
            "AWS_SECRET_KEY env variable is missing, please modify and run the support-files/env_variables.sh script"
        )
    print("AWS_SECRET_KEY is populated")


def ssh_key_missing():
    ssh_key_missing = exists("../keys/aws-key.pub")

    if not ssh_key_missing:
        raise SshKeyMissing(
            "aws-key.pub is not populated. Please run the command specified in the README file and place it inder the keys directory"
        )
    print("aws-key.pub is populated")


aws_access_key()
aws_secret_key()
ssh_key_missing()
