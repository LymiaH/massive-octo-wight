setup;
%%
% From project description page
annotDir = fullfile(pwd,'PennFudanPed','Annotation');

files = dir(annotDir); files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = fullfile(annotDir, files(ii).name);
    record = PASreadrecord(fileName);
    input_image = imread(fullfile(pwd, record.imgname));
    main_img = imshow(input_image); hold on;
    for jj = 1 : length(record.objects)
        pause(0.05);
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        img_over = rgb2gray(imcrop(input_image, bbox));
        img_over_h = imshow(img_over);
        set(img_over_h, 'XData', get(img_over_h, 'XData') + bbox(1) - 1);
        set(img_over_h, 'YData', get(img_over_h, 'YData') + bbox(2) - 1);
        rectangle('Position', bbox, 'EdgeColor','g','LineWidth',2);
    end
    negatives = generate_negatives(record);
    for jj = 1 : length(negatives)
        pause(0.05);
        bbox = negatives{jj};
        img_over = rgb2gray(imcrop(input_image, bbox));
        img_over_h = imshow(img_over);
        set(img_over_h, 'XData', get(img_over_h, 'XData') + bbox(1) - 1);
        set(img_over_h, 'YData', get(img_over_h, 'YData') + bbox(2) - 1);
        rectangle('Position', bbox, 'EdgeColor','r','LineWidth',2);
    end
    hold off;
    pause(0.2);
end
