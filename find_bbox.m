function find_bbox(handles, net, path, ratio, interval, percent_minimum)
    if nargin < 3
        path = 'http://exchange.aaa.com/wp-content/uploads/2014/03/Pedestrian-Safety.jpg';
    end
    if nargin < 4
        ratio = 2.7699;
    end
    if nargin < 5 || interval < 1
        img_size = size(imread(path));
        interval = ceil(min(img_size(1:2))/16);
    end
    interval = ceil(max(1, interval));
    if nargin < 6 || percent_minimum < 0
       percent_minimum = [0.05 0.2];
    end
    percent_minimum = max(0, percent_minimum);
    
    results_find = test_net_find(interval, ratio, net, path, percent_minimum);
    
    results_peak = get_peaks(results_find, interval);
    
    %This lets the image show up in the GUI
    if isa(handles,'struct')
        axes(handles.axes1)
    end
    
    imshow(imread(path));
    
    for ii = 1: length(results_peak)
        bbox = results_peak{ii}.bbox;
        bbox(3:4) = bbox(3:4)- bbox(1:2);
        rectangle('Position', bbox, 'EdgeColor','g','LineWidth',2);
        text(bbox(1)-10, bbox(2)-10, sprintf('%.3f', results_peak{ii}.score), 'Color', 'red','FontSize',14);
    end
end