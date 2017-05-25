setup;
rng('default');
rng(1);
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(path_images);
mkdir(path_positives);
mkdir(path_negatives);

annotDir = fullfile(pwd,'PennFudanPed','Annotation');
files = dir(annotDir); files(1:2) = [];
for ii = 1 : length(files)
    fileName = fullfile(annotDir, files(ii).name);
    record = PASreadrecord(fileName);
    input_image = imread(fullfile(pwd, record.imgname));
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        temp_image = imcrop(input_image, bbox);
        %save to positives
        imwrite(temp_image, fullfile(path_positives, strcat(files(ii).name(1:end-4), '_pos.png')))
    end
    negatives = generate_negatives(record);
    for jj = 1 : length(negatives)
        bbox = negatives{jj};
        temp_image = imcrop(input_image, bbox);
        %save to negatives
        imwrite(temp_image, fullfile(path_negatives, strcat(files(ii).name(1:end-4), '_neg.png')))
    end
end
