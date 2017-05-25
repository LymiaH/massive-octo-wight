function [ negatives ] = generate_negatives( record )
%GENERATE_NEGATIVES Generates negative sample bounding boxes
    %Create a collision mask from the bounding boxes
%     collision_mask = zeros(record.imgsize(1), record.imgsize(2))
%     for jj = 1 : length(record.objects)
%         bbox = record.objects(jj).bbox;
%         bbox(3:4) = bbox(3:4) - bbox(1:2);
%         mask_fill_rectangle(collision_mask, bbox(1), bbox(2), bbox(3),
%         bbox(4))
%     end
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
           negatives{length(negatives) + 1} = bbox;
        end
    end
end