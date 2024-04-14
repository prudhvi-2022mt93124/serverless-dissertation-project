const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");


exports.handler = async (event, context) => {
    const snsClient = new SNSClient({ region: 'ap-south-1' });

    const message = {
        eventType: 'order_created',
        data: event // Pass any data you want to include in the message
    };
    const params = {
        TopicArn: 'arn:aws:sns:ap-south-1:471112983152:create_order_topic_v1', // Replace with your SNS topic ARN
        Message: JSON.stringify(message),
        Subject: 'order_created', // Optional subject
    };
    try {
        const command = new PublishCommand(params);

        // Publish the message to the SNS topic
        const response = await snsClient.send(command);

        console.log('Message published:', response.MessageId);

        return {
            statusCode: 200,
            body: JSON.stringify({ MessageId: response.MessageId })
        };
    }
    catch (err) {
        console.error('Error publishing message:', err);

        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Error publishing message' })
        };
    }
};