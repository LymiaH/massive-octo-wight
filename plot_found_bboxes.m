function plot_found_bboxes(bboxes, width, height)
    if nargin < 3
       width = 0;
       height = 0;
    end
    for index = 1:length(bboxes)
        bbox = bboxes{index}.bbox;
        width = max(width, bbox(3));
        height = max(height, bbox(4));
    end
%     data = zeros(width, height);
%     for index = 1:length(bboxes)
%         bbox = bboxes{index}.bbox;
%         score = bboxes{index}.score;
%         data(bbox(1),bbox(2)) = score;
%     end
%     surf(data);
    X = zeros(1,length(bboxes));
    Y = zeros(1,length(bboxes));
    Z = zeros(1,length(bboxes));
    C = zeros(1,length(bboxes));
    for index = 1:length(bboxes)
        bbox = bboxes{index}.bbox;
        score = bboxes{index}.score;
        if score > 0.6 
            X(index) = bbox(1);
            Y(index) = bbox(2);
            Z(index) = score;
            C = (bbox(3)-bbox(1))*(bbox(4)-bbox(2))/10;
        end
    end
    scatter3(X, Y, Z, C);
end