import json
from typing import Any, Dict, TypedDict
from config import config
from sns_helper import SNSHelper


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

    try:
        sns_helper = SNSHelper(topic_arn=config.SNS_ARN)
        sns_helper.subscribe(email)
    except Exception as e:
        return Response(
            statusCode=500, body=json.dumps({"error": f"Subscription failed: {str(e)}"})
        )
    return Response(
        statusCode=200, body=json.dumps({"message": "Subscription successful"})
    )


def notification_handler(event: Dict[str, Any], _) -> Response:
    """Publishes messages to SNS topic.

    Args:
        event (dict): The event data from SNS.
        _: Unused context object.

    Returns:
        Response: A response indicating the processing status.
    """
    event_body = json.loads(event["body"])
    name = event_body.get("name")
    description = event_body.get("description")
    date = event_body.get("date")

    if not all([name, date, description]):
        return Response(
            statusCode=400,
            body=json.dumps({"error": "Name, date, and description are required"}),
        )
    try:
        sns_helper = SNSHelper(config.SNS_ARN)
        message = f"Event: {name}\nDescription: {description}\nDate: {date}"
        sns_helper.notify(message)
    except Exception as e:
        return Response(
            statusCode=500, body=json.dumps({"error": f"Notification failed: {str(e)}"})
        )
    return Response(
        statusCode=200, body=json.dumps({"message": "Notification processed"})
    )
