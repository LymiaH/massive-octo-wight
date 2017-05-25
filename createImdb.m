%This function creates an image database
%Created with reference to https://au.mathworks.com/matlabcentral/answers/328403-creating-an-imdb-structure
function imdb = createImdb(folder,net)

	%create a struct
    imdb = struct();

    %Have a folder with images that have pedestrians and images that don't
    positives = dir([folder '\positives\*.png']);
    
    %negatives = dir([folder '\nonPedestrian\*.png']);
    negatives =  dir([folder '\negatives\*.png']);
    
    image = imread([folder '\positives\', positives(1).name]);
    im_ = single(image) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = im_ - net.meta.normalization.averageImage ;
	
	
    [height, width, dim] = size(im_);

    numPos = numel(positives);
    numNeg = numel(negatives);

    totalNumImages = numPos + numNeg;

    %initialize some of the strucutres

    meta.sets = {'train','val'};
    meta.classes = {'pedestrian','Non-pedestrian'};

    %Initialize image matrix
    images.data = zeros(height, width, dim, totalNumImages, 'single');
    %images.data_average = zeros(height, width, channel,'single');
    
    %Initialize one label per image
    images.labels = zeros(1,totalNumImages);

    %Initialize set identifying matrix
    images.set = zeros(1,totalNumImages);


    %numImgsTrain = 0; 
    % loading positive samples
    for i=1:numPos
        im = single(imread([folder '\positives\', positives(i).name]));
        im = imresize(im, net.meta.normalization.imageSize(1:2)) ;
        im = im - net.meta.normalization.averageImage ;

        images.data(:,:,:,i) = im;
        images.labels(i) = 1;

        % in this case we select the set (train/val) randomly

        if(randi(10, 1) > 7) % 70% for training and 30% for validation

            images.set(i) = 1; 
           % images.data_average = images.data_average + im; 
        %    numImgsTrain = numImgsTrain + 1;

        else
            images.set(i) = 2;
        end

    end


    % loading negative samples

    for i=1:numNeg

      %im = single(imread([folder '\nonPedestrian\', negatives(i).name]));
      im = single(imread([folder '\negatives\', negatives(i).name]));
      im = imresize(im, net.meta.normalization.imageSize(1:2)) ;
      im = im - net.meta.normalization.averageImage ;

      images.data(:,:,:, numPos+numNeg+i) = im;

      images.labels(numPos+numNeg+i) = 2;

      % in this case we select the set (train/val) randomly

      if(randi(10, 1) > 6) 
        images.set(numPos+numNeg+i) = 1; 
       % images.data_average = images.data_average + im;
       % numImgsTrain = numImgsTrain + 1;

      else

        images.set(numPos+numNeg+i) = 2;

      end

    end
    
   % imageMean = mean(images.data(:));
   % images.data_average = images.data_average./numImgsTrain;
    %images.data = images.data - imageMean;
    
    imdb.meta = meta;
    imdb.images = images;

end