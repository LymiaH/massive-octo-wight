%This function takes a pretrained CNN, modifies it and trains it to
%recognise pedestrians.
%This was made with reference to code found on https://github.com/vlfeat/matconvnet/issues/318
function net = train_net_for_pedestrian_detection(pretrainedPath)
    %Variable for storing the modified network
    net = [];

    % Load the pretrained network
    pretrained_net = load(pretrainedPath);

    % The modifed network will use all layers except the last 2.
    net.layers = pretrained_net.layers(1:end-2);

    % Add a fully connected convolution layrer and a softmax loss layer for
    % classification.
    net.layers{end+1} = struct('name', 'fc8',...
                               'type', 'conv',...
                               'weights', {{0.005*randn(1,1,4096,2, 'single'), zeros(1,2,'single')}},...
                               'learningRate', [0.005 0.002],...
                               'stride', [1 1],...
                               'pad', [0 0 0 0]);
    net.layers{end+1} = struct('name', 'prob',...
                               'type', 'softmaxloss');
    
                      
    %Set opts
    opts.batchSize = 100;
    opts.numEpochs = 6 ;
    opts.continue = true ;
    opts.gpus = [] ;
    opts.learningRate = 0.001 ;
    opts.weightDecay = 0.0005 ;
    
    %Call createImdb function to get image database to train
    imdb = createImdb('Images',pretrained_net);
     
    %Take the average image out before trainning the data
    imageMean = mean(imdb.images.data(:));
   % images.data_average = images.data_average./numImgsTrain;
    imdb.images.data = imdb.images.data - imageMean;
    
    %Train the CNN
    [net,info] = cnn_train(net,imdb,@getBatch,opts);
	
    %Set some of the meta data
    net.meta.inputs.name = 'data';
    net.meta.inputs.size = [224,224,3,10];
    net.meta.imageMean = imageMean;
    net.meta.normalization.imageSize = [224,224,3,10];
    net.meta.normalization. border = [32, 32];
    net.meta.normalization. cropSize = [0.8750, 0.8750];
    net.meta.normalization.interpolation = 'bilinear';
    net.meta.classes.description = imdb.meta.classes;
    
	%Makes a directory for net to be stored in 
    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir('data/trainedNet/');
    save('data/trainedNet/trainedNet.mat','-struct','net');
    
    %Upgrade to current version of Matconvnet and fills in missing default values. 
    net = vl_simplenn_tidy(net);
 
end