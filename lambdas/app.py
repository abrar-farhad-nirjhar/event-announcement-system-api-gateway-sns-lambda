import json
from typing import Any, Dict, TypedDict


class Response(TypedDict):
    """Response structure for the lambda function"""

    statusCode: int
    body: str


def subscription_handler(event: Dict[str, Any], _) -> Response:
    """Handles SNS subscription.

    This lambda function is triggered by api gateway with the email
    address in the event body, it subscribes the email to the SNS topic.

    Args:
        event (dict): The event data from API Gateway.
        _: Unused context object.

    Returns:
        Response: A response indicating the subscription status.
    """
    event_body = json.loads(event["body"])
    email = event_body.get("email")

    if not email:
        return Response(statusCode=400, body=json.dumps({"error": "Email is required"}))

    # Subscribe the email to the SNS topic
    # sns_client.subscribe(TopicArn=sns_topic_arn, Protocol="email", Endpoint=email)

    return Response(
        statusCode=200, body=json.dumps({"message": "Subscription successful"})
    )


def notification_handler(event: Dict[str, Any], _) -> Response:
    """Handles SNS notifications.

    This lambda function is triggered by SNS when a new event announcement
    is published. It processes the notification and performs necessary actions.

    Args:
        event (dict): The event data from SNS.
        _: Unused context object.

    Returns:
        Response: A response indicating the processing status.
    """
    # for record in event["Records"]:
    #     sns_message = record["Sns"]["Message"]
    #     # Process the SNS message (e.g., log it, send emails, etc.)

    return Response(
        statusCode=200, body=json.dumps({"message": "Notification processed"})
    )
