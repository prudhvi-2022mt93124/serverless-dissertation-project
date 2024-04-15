exports.handler = async (event, context) => {

    console.log('Message subscribed:', event);
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from subscriber Lambda!'),
    };
    return response;
};