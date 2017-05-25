%This function creates an image database
%Created with reference to https://au.mathworks.com/matlabcentral/answers/328403-creating-an-imdb-structure
function imdb = createImdb(folder,net)

	%create a struct
    imdb = struct();

    %Get the folder with images that have pedestrians and a folder with images that aren't pedestrians
    positives = dir([folder '\positives\*.png']);
    negatives =  dir([folder '\negatives\*.png']);
    
	%read the first image in the positive folder and get normalisation size
    image = imread([folder '\positives\', positives(1).name]);
    im_ = single(image) ; 
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = im_ - net.meta.normalization.averageImage ;
	
	%Get the height, width, dim of the normalised image
    [height, width, dim] = size(im_);

	%Get the number of positive images
    numPos = numel(positives);
	
	%Get the number of negative images
    numNeg = numel(negatives);

	%Get the total number of images
    totalNumImages = numPos + numNeg;

    %initialize some of the strucutres
	%Training Sets and validation Sets
    meta.sets = {'train','val'};
	
	%Pedestrian and nonpedestrian classes
    meta.classes = {'pedestrian','Non-pedestrian'};

    %Initialize image matrix
    images.data = zeros(height, width, dim, totalNumImages, 'single');
    
    %Initialize one label per image
    images.labels = zeros(1,totalNumImages);

    %Initialize set identifying matrix
    images.set = zeros(1,totalNumImages);

    % Setting positives for training
    for i = 1:numPos
        im = single(imread([folder '\positives\', positives(i).name]));
        im = imresize(im, net.meta.normalization.imageSize(1:2)) ;
        im = im - net.meta.normalization.averageImage ;

        images.data(:,:,:,i) = im;
        images.labels(i) = 1;

        %Randomly train images
        if(randi(10, 1) > 7) % 70% for training and 30% for validation
            images.set(i) = 1; 
        else
            images.set(i) = 2;
        end
    end

    % Setting Negatives for training
    for i = 1:numNeg
      im = single(imread([folder '\negatives\', negatives(i).name]));
      im = imresize(im, net.meta.normalization.imageSize(1:2)) ;
      im = im - net.meta.normalization.averageImage ;

      images.data(:,:,:, numPos+numNeg+i) = im;
      images.labels(numPos+numNeg+i) = 2;

      %Randomly train images
      if(randi(10, 1) > 6) 
        images.set(numPos+numNeg+i) = 1; 
      else
        images.set(numPos+numNeg+i) = 2;
      end
    end
    
	%Finally store the data into the imdb struct
    imdb.meta = meta;
    imdb.images = images;

end