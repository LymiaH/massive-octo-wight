function test_net(net)
    % Obtain and preprocess an image.

   %im = imread('F:\CITS4402\FudanPed00001.png') ;
    %im = imread('E:\CITS4402\Data_toolkit\PennFudanPed\PNGImages\PennPed00096.png');
   %im = imread('E:\CITS4402\Images\notPedestrians\cat.jpg');
    %im = imread('F:\CITS4402\pic.png');
 % im =imread('http://exchange.aaa.com/wp-content/uploads/2014/03/Pedestrian-Safety.jpg');
    im=imread('.\PennFudanPed\PNGImages\FudanPed00014.png');
    net.layers{end}.type = 'softmax';
   

   
    %Slide a small window over the image. Push the window through to
    %vl_simplenn . So probably need a loop
    %If it thinks its a pedestrian then, Draw bounding box around and put confidence over box
    %Might need an if statement if window too small.

   tic;
    %Height of pedestrians in the image database are between 180-390
    %pixels.
    %Window size should be big enough to see the pedestrians 
    windowSize = [100,260];
    
    %Corner of window
    Xmin = 1; 
    Ymin = 1;
    
    [Ymax, Xmax, d] = size(im);
 
    %need error checking
bbox = struct();
bbox.box = [];
count = 1;
    %Loop through the possible windows 
    for y = Ymin:(windowSize(2)/2):(Ymax - windowSize(2))
        for x = Xmin:(windowSize(1)/2):(Xmax - windowSize(1))
            windowBox =  [x, y, windowSize(1)-1, windowSize(2)-1];
            %windowBox = [20,20,100,300]
            %Crop the window out of the image
            windowIm = imcrop(im, windowBox);
            im_ =single(windowIm);
            im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
            im_ = im_ - net.meta.imageMean ;
            res = vl_simplenn(net,im_);
            scores = squeeze(gather(res(end).x)) ;
            [bestScore, best] = max(scores) ;
            
            %If the window detects a pedestrian
           if(best ==  1 && bestScore>=0.80)
                bbox.box{count} = windowBox;
                bbox.score{count} = bestScore;
                count = count + 1;
%                figure(1) ; clf ;  imagesc(im) ; 
%                rectangle('Position', windowBox, 'EdgeColor','g','LineWidth',2);
%                title(sprintf('%s (%d), score %.3f',...
%                  net.meta.classes.description{best}, best, bestScore)) ;
           end
            
            
        end
    end
    

    %To deal with overlap, loop over the bboxes to find where x coordinate
    %is the same. Then take the bbox with the highest confidence and show
    %that bbox.
	for ii = 1:length(bbox.box)
		for jj = ii+1:length(bbox.box)
            if jj <= length(bbox.box)&& ~isempty(bbox.box{ii}) && ~isempty(bbox.box{jj})

                if bbox.box{ii}(1) == bbox.box{jj}(1) 
                     if bbox.score{ii}>bbox.score{jj}

                         bbox.box{jj} = [];
                         bbox.score{jj}=[];
                     else

                         bbox.box{ii} =[];
                         bbox.score{ii}=[];

                     end
                end


            end
        end
      
    end
    
    %Put bounding boxes over the image
    figure(1) ; clf ;  imagesc(im) ; 
    for ii= 1:length(bbox.box)
        if~isempty(bbox.box{ii})
     rectangle('Position', bbox.box{ii}, 'EdgeColor','g','LineWidth',2);
     text(bbox.box{ii}(1)-10, bbox.box{ii}(2)-10, sprintf('%.3f', bbox.score{ii}), 'Color', 'red','FontSize',14);
        end  
    end
    
            
elapsedTime = toc*1000

end