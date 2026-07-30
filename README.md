# Event-Driven Order System

A decoupled order processing pipeline using SQS and SNS, demonstrating real event-driven architecture — tested locally via LocalStack.

## What it does

Orders are placed into an SQS queue. A Lambda function automatically picks up and processes each order (no manual invocation), then publishes a confirmation notification via SNS, which broadcasts to any subscribers.

## Architecture
- **SQS (order-queue)**: holds incoming orders until a worker (Lambda) is ready to process them
- **Lambda** (lambda_function.py): automatically triggered by new SQS messages via an event source mapping; processes the order and publishes a confirmation
- **SNS (order-notifications)**: broadcasts the confirmation to all subscribers
- **IAM Role**: scoped to only sns:Publish on the specific topic

## Key concept: SQS vs SNS

- **SQS** = one-to-one, pull-based. One worker picks up and processes each message.
- **SNS** = one-to-many, push-based. One message broadcasts to every subscriber simultaneously.

## Key concept: message deletion isn't automatic

Receiving a message from SQS doesn't delete it — it just becomes temporarily invisible. The consumer must explicitly delete it after successful processing. This protects against data loss if a worker crashes mid-processing: the message becomes visible again after a timeout, so another attempt can pick it up.

## Automatic triggering (no manual Lambda invoke)

Unlike earlier projects where Lambda was manually invoked, this project uses a Lambda **event source mapping** on the SQS queue — Lambda automatically polls the queue in the background and invokes itself whenever a new message arrives.

## Tech stack
- Python 3.12 (boto3)
- AWS SQS, SNS, Lambda, IAM
- LocalStack (local AWS emulation)
- Jenkins (CI pipeline)
