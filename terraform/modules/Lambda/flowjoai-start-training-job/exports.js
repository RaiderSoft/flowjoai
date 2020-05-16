const AWS = require('aws-sdk');
const sagemaker = new AWS.SageMaker();
const documentClient = new AWS.DynamoDB.DocumentClient();

const crypto = require("crypto");

const generateUUID = () => crypto.randomBytes(16).toString("hex");

exports.handler = async(event) => {
    try {
        const uuid = generateUUID();
        
        const params = {
            TrainingJobName: uuid,
            AlgorithmSpecification: {
                AlgorithmName: 'arn:aws:sagemaker:us-east-2:914873542326:algorithm/flowjoai-v1',
                TrainingInputMode: 'File',
                EnableSageMakerMetricsTimeSeries: false
            },
            HyperParameters: { epochs: '10', lr: '0.01' },
            RoleArn: 'arn:aws:iam::914873542326:role/dynamo-lambda-crud',
            InputDataConfig: [{
                ChannelName: 'TRAINING',
                DataSource: {
                    S3DataSource: {
                        S3DataType: "S3Prefix",
                        S3Uri: "s3://flowjoai-v1/training/v1",
                    }
                }
            }],
            OutputDataConfig: { S3OutputPath: 's3://flowjoai-v1/outputs/v1' },
            ResourceConfig: { InstanceType: 'ml.m4.xlarge', InstanceCount: 1, VolumeSizeInGB: 1 },
            StoppingCondition: { MaxRuntimeInSeconds: 36000 }

        };

        const response = await sagemaker.createTrainingJob(params).promise();

        const created = new Date().valueOf();

        const modelName = `flowjoai-v1-${uuid}`;

        const modelItem = {
            "uuid": uuid,
            "completed": false,
            "created": `${created}`,
            "modelStatus": "submitted",
            "modelName": modelName,
        }

        const data = await documentClient.put({
            TableName: 'flowjoai-models',
            Item: modelItem
        }).promise();

        return {
            statusCode: 200,
            body: modelItem,
        };

    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
};
