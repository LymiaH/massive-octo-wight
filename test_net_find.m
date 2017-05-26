function [results] = test_net_find(interval, ratio, net, path)
    %ratio is y/x
    if nargin > 3
       error('Too many inputs')
    end
    if nargin < 1
        interval = 16;
    end
    if nargin < 2
        ratio = 2.7699;
    end
    % if the system should use the width or height as the basis
    if ratio > 1
        use_width = true;
    else
        use_width = false;
        ratio = 1 / ratio;
    end

    if nargin < 3
        net = load(fullfile(pwd,'data','trainedNet','trainedNet.mat'));
    end
    net.layers{end}.type = 'softmax';
    if nargin < 4
        path = 'http://exchange.aaa.com/wp-content/uploads/2014/03/Pedestrian-Safety.jpg';
    end
    im = imread(path);

    figure(1);
    imagesc(im);
    bbox_rect = rectangle('Position', [0,0,1,1], 'EdgeColor','g','LineWidth',2);
    bbox_text = text(0, 0, sprintf('%.3f', 0), 'Color', 'red','FontSize',14);
    [im_height, im_width, ~] = size(im);
    
    results = cell(1,0);
    
    for top = 1:interval:im_height-interval
        for left = 1:interval:im_width-interval
            best_bottom_right = [0,0];
            best_score = 0;
            %for each x, y pair
            if ratio <= 0
                for bottom = top+interval:interval:im_height
                    for right = left+interval:interval:im_width
                        score = processing_step(top, left, bottom, right, net, im, bbox_rect, bbox_text);
                        if score > best_score
                            best_score = score;
                            best_bottom_right = [bottom, right];
                        end
                    end
                end
            else
                if use_width
                    for right = left+interval:interval:im_width
                        width = right - left;
                        height = round(width * ratio);
                        bottom = top + height;
                        if bottom > im_height
                            break
                        end
                        score = processing_step(top, left, bottom, right, net, im, bbox_rect, bbox_text);
                        if score > best_score
                            best_score = score;
                            best_bottom_right = [bottom, right];
                        end
                    end
                else
                    for bottom = top+interval:interval:im_height
                        height = bottom - top;
                        width = round(height * ratio);
                        right = left + width;
                        if right > im_width
                            break
                        end
                        score = processing_step(top, left, bottom, right, net, im, bbox_rect, bbox_text);
                        if score > best_score
                            best_score = score;
                            best_bottom_right = [bottom, right];
                        end
                    end
                end
            end
            %endfor each x, y pair
            if best_score > 0
                bottom = best_bottom_right(1);
                right = best_bottom_right(2);
                best_bbox = [left, top, right, bottom];
                index = length(results) + 1;
                results{index}.bbox = best_bbox;
                results{index}.score = best_score;
                update_rect = best_bbox;
                update_rect(3:4) = update_rect(3:4) - update_rect(1:2);
                update_bbox(bbox_rect, bbox_text, update_rect, best_score);
                pause(0);
            end
        end
    end
end

function update_bbox(bbox_rect, bbox_text, bbox, score)
    bbox_rect.Position = bbox;
    bbox_text.Position = [bbox(1) - 10, bbox(2) - 10];
    bbox_text.String = sprintf('%.3f', score);
end

function [ score ] = processing_step(top, left, bottom, right, net, im, bbox_rect, bbox_text)
    bbox = [left, top, right - left, bottom - top];
    score = 0;
    im_ = single(imcrop(im, bbox));
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = im_ - net.meta.imageMean;
    res = vl_simplenn(net,im_);
    scores = squeeze(gather(res(end).x));
    [bestScore, best] = max(scores);
    if best == 1
        score = bestScore;
        %update_bbox(bbox_rect, bbox_text, bbox, score);
        %pause(0);
    end
    %update_bbox(bbox_rect, bbox_text, bbox, score);
    %pause(0);
end