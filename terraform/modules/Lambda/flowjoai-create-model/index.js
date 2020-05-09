const AWS = require('aws-sdk');
const sagemaker = new AWS.SageMaker();

exports.handler = async(event) => {
    try {
        const { uuid } = JSON.parse(event).body

        const createModelParams = {
            ModelName: uuid,
            Containers: [{
                Image: '914873542326.dkr.ecr.us-east-2.amazonaws.com/flowjoai-pytorch-inference-v1:latest',
                Mode: 'SingleModel',
                ModelDataUrl: `s3://flowjoai-v1/outputs/v1/${uuid}/output/model.tar.gz`
            }],
            ExecutionRoleArn: 'arn:aws:iam::914873542326:role/dynamo-lambda-crud',
            VpcConfig: {
                SecurityGroupIds: ['sg-3e473e53'],
                Subnets: ['subnet-e22ce8ae', 'subnet-92fc60e8', 'subnet-2365434b']
            },
            EnableNetworkIsolation: true
        }
        
        const response = await sagemaker.createModel(createModelParams).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(response),
        };
    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
};
