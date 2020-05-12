const AWS = require('aws-sdk');
const sagemaker = new AWS.SageMaker();

exports.handler = async(event) => {
    try {
        console.log(event)
        const { uuid } = JSON.parse(event).body
    console.log(JSON.parse(event))
        const createEndpointConfigParams = {
            EndpointConfigName: uuid,
            ProductionVariants: [{
                VariantName: 'variant-name-1',
                ModelName: uuid,
                InitialInstanceCount: 1,
                InstanceType: 'ml.m4.xlarge',
                InitialVariantWeight: 1
            }],
        }

        const createEndpointConfigResponse = await sagemaker.createEndpointConfig(createEndpointConfigParams).promise();

        const params = {
            EndpointConfigName: uuid,
            EndpointName: uuid,
        };

        const createEndpointResponse = await sagemaker.createEndpoint(params).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(createEndpointResponse),
        };
    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
};
