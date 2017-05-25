setup;
%% 
% From project description page
baseDir = '.\';
annotDir = [baseDir 'PennFudanPed\Annotation\'];

files = dir(annotDir); files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    input_image = imread([baseDir record.imgname]);
    main_img = imshow(input_image); hold on;
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        rectangle('Position', bbox, 'EdgeColor','g','LineWidth',2);
    end
    hold off;
    pause(1);
end
