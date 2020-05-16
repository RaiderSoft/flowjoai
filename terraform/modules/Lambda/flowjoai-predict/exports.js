const AWS = require('aws-sdk');
const sagemakerruntime = new AWS.SageMakerRuntime();

exports.handler = async(event) => {
    try {
        const uuid = event.uuid;
        const s3FilePath = 's3://flowjoai-v1/training/v1'

        const params = {
            Body: JSON.stringify({ 's3_file_path': s3FilePath }),
            EndpointName: uuid,
            Accept: 'application/json',
            ContentType: 'application/json'
        };

        const response = await sagemakerruntime.invokeEndpoint(params).promise();
        console.log(response)

        return {
            statusCode: 200,
            body: {},
        };

    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
};
