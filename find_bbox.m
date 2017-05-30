function find_bbox(handles, net, path, interval)
    if nargin < 3
        path = 'http://exchange.aaa.com/wp-content/uploads/2014/03/Pedestrian-Safety.jpg';
    end
    if nargin < 4
        interval = 32;
    end
   
    results_find = test_net_find(interval, 2.7699, net, path);
    
    results_peak = get_peaks(results_find, interval);
    
    %This lets the image show up in the GUI
    axes(handles.axes1)
    
    imshow(imread(path));
    
    for ii = 1: length(results_peak)
        bbox = results_peak{ii}.bbox;
        bbox(3:4) = bbox(3:4)- bbox(1:2);
        rectangle('Position', bbox, 'EdgeColor','g','LineWidth',2);
        text(bbox(1)-10, bbox(2)-10, sprintf('%.3f', results_peak{ii}.score), 'Color', 'red','FontSize',14);
    end
end