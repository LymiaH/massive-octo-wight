function [] = mask_fill_rectangle(target, x, y, width, height )
%MASK_FILL_RECTANGLE Summary of this function goes here
%   Detailed explanation goes here
    for xx = x:x+width-1
        for yy = y:y+height-1
            target(xx, yy) = 1;
        end
    end
end
