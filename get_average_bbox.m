setup;
path_annot = fullfile(pwd,'PennFudanPed','Annotation');
files = dir(path_annot);
files(1:2) = []; % ignore . and ..
total_ratio = 0;
total_bbox = 0;

for ii = 1 : length(files)
    fileName = fullfile(path_annot, files(ii).name);
    record = PASreadrecord(fileName);
    for jj = 1 : length(record.objects)
        pause(0.05);
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        total_ratio = total_ratio + bbox(4)/bbox(3);
        total_bbox = total_bbox + 1;
    end
end

disp(total_ratio / total_bbox);
% 2.7699
