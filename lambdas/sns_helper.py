import boto3


class SNSHelper:
    def __init__(self, topic_arn):
        self.sns_client = boto3.client("sns")
        self.topic_arn = topic_arn

    def subscribe(self, email) -> None:
        """Subscribe an email address to the SNS topic."""
        self.sns_client.subscribe(
            TopicArn=self.topic_arn, Protocol="email", Endpoint=email
        )

    def notify(self, message: str) -> None:
        """Publish a notification message to the SNS topic."""
        self.sns_client.publish(TopicArn=self.topic_arn, Message=message)
