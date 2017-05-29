function [output] = get_peaks(bboxes, interval, width, height)
    if nargin < 2
        interval = 32;
    end
    if nargin < 4
       width = 0;
       height = 0;
        for index = 1:length(bboxes)
            bbox = bboxes{index}.bbox;
            width = max(width, bbox(3));
            height = max(height, bbox(4));
        end
    end
    width = floor(width / interval);
    height = floor(height / interval);
    data = zeros(height, width);
    databb = cell(height, width);
    for index = 1:length(bboxes)
        bbox = bboxes{index}.bbox;
        score = bboxes{index}.score;
        data(floor(bbox(2) / interval) + 1, floor(bbox(1) / interval) + 1) = score;
        databb{floor(bbox(2) / interval) + 1, floor(bbox(1) / interval) + 1} = bbox;
    end
    %imshow(data);

    surf(data);
    [x, y] = find(imregionalmax(data));
    hold on;
    temp = zeros(1, length(x));
    output = cell(1, length(x));
    for i = 1: length(temp)
       temp(i) = data(x(i),y(i));
       output{i}.score = data(x(i),y(i));
       output{i}.bbox = databb{x(i),y(i)};
    end
    
    plot3(y, x, temp,'r*','MarkerSize',24);
    hold off;
end
