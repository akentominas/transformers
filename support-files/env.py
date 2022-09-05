import os


class AwsAccessKeyMissing(Exception):
    pass


class AwsSecretKeyMissing(Exception):
    pass


def aws_access_key():
    aws_access_key = os.environ.get("AWS_ACCESS_KEY")

    if not aws_access_key:
        raise AwsAccessKeyMissing(
            "AWS_ACCESS_KEY env variable is missing, please modify and run the support-files/env_variables.sh script"
        )


def aws_secret_key():
    aws_secret_key = os.environ.get("AWS_SECRET_KEY")

    if not aws_secret_key:
        raise AwsSecretKeyMissing(
            "AWS_SECRET_KEY env variable is missing, please modify and run the support-files/env_variables.sh script"
        )


aws_access_key()
aws_secret_key()
