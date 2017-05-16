%For testing that opencv is working
%From documentation at: http://kyamagu.github.io/mexopencv/matlab/CascadeClassifier.html
xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml');
cc = cv.CascadeClassifier(xmlfile);
im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
boxes = cc.detect(im);
for i=1:numel(boxes)
    im = cv.rectangle(im, boxes{i}, 'Color',[0 255 0], 'Thickness',2);
end
imshow(im)
