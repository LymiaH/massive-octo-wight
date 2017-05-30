function [ negatives ] = generate_negatives( record )
%GENERATE_NEGATIVES Generates negative sample bounding boxes
    
    %calculate the collision boxes
    bboxes = cell(1, length(record.objects));
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        bboxes{jj} = bbox;
    end

    negatives = {};
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        %Randomly shift the box such that it does not overlap
        found = false;
        for atmp = 1:100
            bbox(1) = randi([1,record.imgsize(1) - bbox(3)]);
            bbox(2) = randi([1,record.imgsize(2) - bbox(4)]);
            collision = false;
            for kk = 1 : length(record.objects)
                if bbox_collision_ltwh(bboxes{kk}, bbox)
                    collision = true;
                    break
                end
            end
            if collision
                continue
            end
            found = true;
            break
        end
        if found
           negatives{end + 1} = bbox;
        end
        %Divide the positive into quandrants for negatives
        bbox = record.objects(jj).bbox;
        bbox_hsize = floor(bbox(3:4) - bbox(1:2))./2;
        negatives{end + 1} = [bbox(1), bbox(2), bbox_hsize(1), bbox_hsize(2)];
        negatives{end + 1} = [bbox(1) + bbox_hsize(1), bbox(2), bbox_hsize(1), bbox_hsize(2)];
        negatives{end + 1} = [bbox(1), bbox(2) + bbox_hsize(2), bbox_hsize(1), bbox_hsize(2)];
        negatives{end + 1} = [bbox(1) + bbox_hsize(1), bbox(2) + bbox_hsize(2), bbox_hsize(1), bbox_hsize(2)];
    end
end
