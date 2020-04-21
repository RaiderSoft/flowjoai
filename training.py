import os
import sys
import logging
import argparse

# REQUEST / RESPONSE
import json

# PYTORCH 
import torch
import torch.utils.data
import torch.utils.data.distributed
from torch import nn
from torch.autograd import Variable

# PYTHON DATAFRAMES AND PARSIN
import pandas
import numpy
import glob

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler(sys.stdout))

class Network(nn.Module):
    def __init__(self, input_size, number_of_classes):
        super(Network, self).__init__()
        
        # Inputs to hidden layer linear transformation
        self.hidden = nn.Linear(input_size, 256)
        # Output layer, number_of_classes
        self.output = nn.Linear(256, number_of_classes)
        
        # Define sigmoid activation and softmax output 
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        # Pass the input tensor through each of our operations
        x = self.hidden(x)
        x = self.sigmoid(x)
        x = self.output(x)
        
        return x

def _get_device():
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")

# USED DURING INFERENCE TO PULL INPUT DATA FROM S3
def _get_s3_file_data_as_dataframe(s3_file_path):
    return pandas.read_csv(s3_file_path, encoding='utf8', engine = 'python')

# USED DURING TRAINING TO PULL ALL INPUT DATA LOADED BY THE ESTIMATOR INTO THE CONTAINER FOR TRAINING AND TESTING
def _get_model_input_dir_files_as_dataframe(model_input_dir_path):
    all_files = glob.glob(model_input_dir_path + "/*.csv")

    parsed_files_dataframes = (pandas.read_csv(file, encoding='utf8', engine = 'python') for file in all_files)

    return pandas.concat(parsed_files_dataframes, axis = 0, ignore_index=True)

# Deserialize the Invoke request body into an object we can perform prediction on // https://sagemaker.readthedocs.io/en/stable/using_pytorch.html#deploy-pytorch-models
def input_fn(request_body, request_content_type):
    device = _get_device()
    if request_content_type == 'application/json':
        request = json.loads(request_body)
        s3_file_path = request.get('s3_file_path')
        
        tensor = _get_s3_file_data_as_dataframe(s3_file_path)

        return tensor.to(device)

# Perform prediction on the deserialized object, with the loaded model // https://sagemaker.readthedocs.io/en/stable/using_pytorch.html#deploy-pytorch-models
def predict_fn(input_data, model):
    device = _get_device()
    model.to(device)
    model.eval()
    with torch.no_grad():
        return model(input_data.to(device))

# Serialize the prediction result into the desired response content type // https://sagemaker.readthedocs.io/en/stable/using_pytorch.html#deploy-pytorch-models
def output_fn(prediction, response_content_type):
    outputs =  prediction.data.cpu().numpy()

#     _, predictions = torch.max(prediction.data, 1)
    
    return json.dumps({'predictions': outputs})
    
def model_fn(model_dir):
    device = _get_device()
    model = torch.nn.DataParallel(Net())
    with open(os.path.join(model_dir, 'model.pth'), 'rb') as f:
        model.load_state_dict(torch.load(f))
    return model.to(device)

def save_model(model, model_dir):
    logger.info("Saving the model.")
    path = os.path.join(model_dir, 'model.pth')
    torch.save(model.cpu().state_dict(), path)
    
# TAKES A DIRECTORY, READS INTO PANDAS DATAFRAME, CONVERTS CLASS LABELS AND VALUES TO TENSORS, FINALLY A PYTORCH DATASET
def _get_inference_data_loader(inference_file, batch_size, is_distributed, **kwargs):
    logger.info("_get_inference_data_loader START")
    inference_data = _get_s3_file_data_as_dataframe(inference_file)
    logger.debug("training_data_len - {}".format(inference_data.shape))

    # GET VALUES, CONVERT TO TENSOR
    inference_data_tensor = torch.tensor(inference_data.values.astype(numpy.float32))
    
    # CONVERT CLASS_LABEL AND VALUES INTO DATASET
    inference_tensor_dataset = torch.utils.data.TensorDataset(inference_data_tensor)
    
    # CHECK IF DISTRIBUTED
    inference_sampler = torch.utils.data.distributed.DistributedSampler(inference_tensor_dataset) if is_distributed else None

    # CREATE DATALOADER FROM DATASET, IF DISTRIBUTED, and OTHER ARGUMENTS
    inference_data_loader = torch.utils.data.DataLoader(dataset = inference_tensor_dataset, batch_size = batch_size, shuffle = inference_sampler is None, **kwargs)
    
    logger.info("_get_inference_data_loader DONE")
    return inference_data_loader

# TAKES A DIRECTORY, READS INTO PANDAS DATAFRAME, CONVERTS CLASS LABELS AND VALUES TO TENSORS, FINALLY A PYTORCH DATASET
def _get_training_data_loader(class_label_header_name, batch_size, training_dir, is_distributed, **kwargs):
    logger.info("_get_training_data_loader START")
    training_data = _get_model_input_dir_files_as_dataframe(training_dir)
    logger.debug("training_data.shape - {}".format(training_data.shape))

    # GET CLASS LABELS COLUMN, CONVERT TO TENSOR
    training_data_class_labels = training_data[class_label_header_name]
    training_data_class_labels_tensor = torch.LongTensor(training_data_class_labels.values)
    training_data_class_labels_len = len(training_data_class_labels.unique())
    
    # GET VALUES WITH NO CLASS LABEL, CONVERT TO TENSOR
    training_data_no_class_label = training_data.drop(class_label_header_name, axis = 1)
    training_data_tensor = torch.tensor(training_data_no_class_label.values.astype(numpy.float32))
    training_data_columns_len = training_data_no_class_label.shape[1]
    
    # CONVERT CLASS_LABEL AND VALUES INTO DATASET
    training_tensor_dataset = torch.utils.data.TensorDataset(training_data_tensor, training_data_class_labels_tensor)
    
    # CHECK IF DISTRIBUTED
    train_sampler = torch.utils.data.distributed.DistributedSampler(training_tensor_dataset) if is_distributed else None

    # CREATE DATALOADER FROM DATASET, IF DISTRIBUTED, and OTHER ARGUMENTS
    training_data_loader = torch.utils.data.DataLoader(dataset = training_tensor_dataset, batch_size = batch_size, shuffle = train_sampler is None, **kwargs)
    
    logger.info("_get_training_data_loader DONE")
    return training_data_loader, training_data_class_labels_len, training_data_columns_len

# TAKES A DIRECTORY, READS INTO PANDAS DATAFRAME, CONVERTS CLASS LABELS AND VALUES TO TENSORS, FINALLY A PYTORCH DATASET
def _get_testing_data_loader(class_label_header_name, batch_size, testing_dir, is_distributed, **kwargs):
    logger.info("_get_testing_data_loader START")
    testing_data = _get_model_input_dir_files_as_dataframe(testing_dir)
    
    # GET CLASS LABELS COLUMN, CONVERT TO TENSOR
    testing_data_class_labels = testing_data[class_label_header_name]
    testing_data_class_labels_tensor = torch.LongTensor(testing_data_class_labels.values)
    
    # GET VALUES WITH NO CLASS LABEL, CONVERT TO TENSOR
    testing_data_no_class_label = testing_data.drop(class_label_header_name, axis = 1)
    testing_data_tensor = torch.tensor(testing_data_no_class_label.values.astype(numpy.float32))
    
    # CONVERT CLASS_LABEL AND VALUES INTO DATASET
    testing_tensor_dataset = torch.utils.data.TensorDataset(testing_data_tensor, testing_data_class_labels_tensor)
    
    # CHECK IF DISTRIBUTED
    testing_sampler = torch.utils.data.distributed.DistributedSampler(testing_tensor_dataset) if is_distributed else None

    # CREATE DATALOADER FROM DATASET, IF DISTRIBUTED, and OTHER ARGUMENTS
    testing_data_loader = torch.utils.data.DataLoader(dataset=testing_tensor_dataset, batch_size= batch_size, shuffle = testing_sampler is None, **kwargs)
    
    logger.info("_get_testing_data_loader DONE")
    return testing_data_loader     

# SET THE SEED FOR GENERATING RANDOM NUMBERS
def _set_torch_seed(args, use_cuda):
    torch.manual_seed(args.seed)
    if use_cuda:
        torch.cuda.manual_seed(args.seed)
        
# INITIALIZE DISTRIBUED ENVIRONMENT
def _initialize_distributed_environment(args):
    world_size = len(args.hosts)
    os.environ['WORLD_SIZE'] = str(world_size)
    host_rank = args.hosts.index(args.current_host)
    os.environ['RANK'] = str(host_rank)
    torch.distributed.init_process_group(backend=args.backend, rank=host_rank, world_size=world_size)
    logger.info('Initialized the distributed environment: \'{}\' backend on {} nodes. '.format(
        args.backend, torch.distributed.get_world_size()) + 'Current host rank is {}. Number of gpus: {}'.format(
        torch.distributed.get_rank(), args.num_gpus))
    return host_rank

def _is_distributed(args):
    return len(args.hosts) > 1 and args.backend is not None

def _use_cuda(args):
    print(args) 
    return args.num_gpus > 0

def _get_network(device, input_size, number_of_classes):
    network = Network(input_size, number_of_classes)
    return network.to(device)

def _get_model_for_machine_type(is_distributed, use_cuda, model):
    device = _get_device()

    if is_distributed and use_cuda:
        # multi-machine multi-gpu case
        logger.debug("Multi-machine multi-gpu: using DistributedDataParallel.")
        return torch.nn.parallel.DistributedDataParallel(model)
    elif use_cuda:
        # single-machine multi-gpu case
        logger.debug("Single-machine multi-gpu: using DataParallel().cuda().")
        return torch.nn.DataParallel(model).to(device)
    # single-machine or multi-machine cpu case
    logger.debug("Single-machine/multi-machine cpu: using DataParallel.")
    return torch.nn.DataParallel(model)

def _get_kwargs(use_cuda):
    return {'num_workers': 1, 'pin_memory': True} if use_cuda else {}

def _average_gradients(model):
    # Gradient averaging.
    size = float(torch.distributed.get_world_size())
    for param in model.parameters():
        torch.distributed.all_reduce(param.grad.data, op=torch.distributed.reduce_op.SUM)
        param.grad.data /= size

def assert_can_track_sagemaker_experiments():
    in_sagemaker_training = 'TRAINING_JOB_ARN' in os.environ
    in_python_three = sys.version_info[0] == 3

    if in_sagemaker_training and in_python_three:
        import smexperiments.tracker

        with smexperiments.tracker.Tracker.load() as tracker:
            tracker.log_parameter('param', 1)
            tracker.log_metric('metric', 1.0)
        
def test(model, test_loader, device):
    model.eval()
    test_loss = 0
    correct = 0
    cross_entropy_loss = torch.nn.CrossEntropyLoss()

    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += cross_entropy_loss(output, target).item()  # sum up batch loss
            pred = output.max(1, keepdim=True)[1]  # get the index of the max log-probability
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)
    logger.info('Test set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        100. * correct / len(test_loader.dataset)))
        
def train(args):
    # IS DISTRIBUED ENVIRONMENT
    is_distributed = _is_distributed(args)
    logger.debug("Distributed training - {}".format(is_distributed))
    
    # IS CUDA ENVIRONMENT
    use_cuda = _use_cuda(args)
    logger.debug("Number of gpus available - {}".format(args.num_gpus))
        
    # GET TORCH DEVICE
    device = torch.device("cuda" if use_cuda else "cpu")

    # CONFIGURE ENVIROMENT
    if is_distributed:
        host_rank = _initialize_distributed_environment(args)
        
    # SET TORCH SEED
    _set_torch_seed(args, use_cuda)

    # GET DATA LOADERS FROM TRAINING AND testing DIRECTORIES
    kwargs = _get_kwargs(use_cuda)
    training_data_loader, training_data_class_labels_len, training_data_columns_len = _get_training_data_loader('CellId', args.batch_size, args.data_dir, is_distributed, **kwargs)
    testing_loader = _get_testing_data_loader('CellId', args.test_batch_size, args.data_dir, is_distributed, **kwargs)
    
    logger.debug("training_data_columns_len - {}".format(training_data_columns_len))
    logger.debug("training_data_class_labels_len - {}".format(training_data_class_labels_len))

    network = Network(training_data_columns_len, training_data_class_labels_len)
    model = network.to(device)

    optimizer = torch.optim.SGD(model.parameters(), lr=args.lr, momentum=args.momentum)
    cross_entropy_loss = torch.nn.CrossEntropyLoss()

    for epoch in range(1, args.epochs + 1):
        model.train()
        for batch_idx, (data, target) in enumerate(training_data_loader, 1):            
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            
            output = model(data)
            
            loss = cross_entropy_loss(output, target)

            loss.backward()
            if is_distributed and not use_cuda:
                _average_gradients(model)
            optimizer.step()
            if batch_idx % args.log_interval == 0:
                logger.debug('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                    epoch, batch_idx * len(data), len(training_data_loader.sampler),
                    100. * batch_idx / len(training_data_loader), loss.item()))
        test(model, testing_loader, device)
    save_model(model, args.model_dir)

    if is_distributed and host_rank == 0 or not is_distributed:
        assert_can_track_sagemaker_experiments()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    print(parser)

    # Data and model checkpoints directories
    parser.add_argument('--batch-size', type=int, default=32, metavar='N',
                        help='input batch size for training (default: 64)')
    parser.add_argument('--test-batch-size', type=int, default=100, metavar='N',
                        help='input batch size for testing (default: 1000)')
    parser.add_argument('--epochs', type=int, default=10, metavar='N',
                        help='number of epochs to train (default: 10)')
    parser.add_argument('--lr', type=float, default=0.01, metavar='LR',
                        help='learning rate (default: 0.01)')
    parser.add_argument('--momentum', type=float, default=0.5, metavar='M',
                        help='SGD momentum (default: 0.5)')
    parser.add_argument('--seed', type=int, default=1, metavar='S',
                        help='random seed (default: 1)')
    parser.add_argument('--log-interval', type=int, default=100, metavar='N',
                        help='how many batches to wait before logging training status')
    parser.add_argument('--backend', type=str, default=None,
                        help='backend for distributed training (tcp, gloo on cpu and gloo, nccl on gpu)')

    # Container environment
    parser.add_argument('--hosts', type=list, default=json.loads(os.environ['SM_HOSTS']))
    parser.add_argument('--current-host', type=str, default=os.environ['SM_CURRENT_HOST'])
    parser.add_argument('--model-dir', type=str, default=os.environ['SM_MODEL_DIR'])
    parser.add_argument('--data-dir', type=str, default=os.environ['SM_CHANNEL_TRAINING'])
    parser.add_argument('--num-gpus', type=int, default=os.environ['SM_NUM_GPUS'])

    train(parser.parse_args())