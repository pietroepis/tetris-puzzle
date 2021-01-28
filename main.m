clear all;
close all;

scheme_name = "./schemes/S06.jpg";
scene_name = "./scenes/P10.jpg";

% classifiers are generated in training.m
load("classifier_bayes.mat");
load("classifier_knn.mat");

% SCENE read (and resize to speed up prediction)
imscene = imread(scene_name);
imscenergb = imresize(imscene, 1);
imsceneycbcr = rgb2ycbcr(imscenergb);

% Pixel colors descriptors for prediction (G, B, Y, Cb and Cr are used)
values = cat(3, imscenergb(:, :, 2:3), imsceneycbcr);
[r, c, ch] = size(values);
values = double(reshape(values, r*c, ch));

predicted = predict(classifier_bayes, values);
predicted = reshape(predicted, r, c);

% closing to remove holes inside of predicted shapes
se = strel("square", 9);
predicted = imclose(predicted, se); 
% median filter to remove scattered random points from background
predicted = medfilt2(predicted, [21 21]); 
% opening to remove possibile residual white regions that are not pieces
se = strel("square", 25);
predicted = imerode(predicted, se);
se = strel("square", 25);
predicted = imdilate(predicted, se);

labeled_scene = bwlabel(predicted);
scene_labels = unique(labeled_scene);

% SCENE shapes features extraction
scene_props = [];
for i = 2:length(scene_labels)
    subImage = imcrop(labeled_scene == scene_labels(i),...
        regionprops(labeled_scene == scene_labels(i), "BoundingBox").BoundingBox);
    subImage = padarray(subImage, [100 100], 0 , "both");
    
    corners = get_corners(subImage);
    im_props = regionprops(subImage, "Eccentricity", "Area", "Perimeter");
    scene_props = [scene_props; corners.Count/8 im_props.Eccentricity im_props.Area/im_props.Perimeter^2 scene_labels(i)];   
end

% SCHEME read, binarization and noise removal
imschemergb = im2double(imread(scheme_name));
imscheme = rgb2gray(imschemergb);
mask = imscheme > 0.39;
mask = medfilt2(mask, [7 7]);

% SCHEME shapes features extraction
labeled_scheme = bwlabel(mask);
scheme_labels = unique(labeled_scheme);
scheme_props = [];
for i = 3:length(scheme_labels)
    subImage = imcrop(labeled_scheme == scheme_labels(i),...
        regionprops(labeled_scheme == scheme_labels(i),"BoundingBox").BoundingBox);
    subImage = padarray(subImage, [100 100], 0 , 'both');
  
    corners = get_corners(subImage);
    im_props = regionprops(subImage, "Eccentricity", "Area", "Perimeter");
    scheme_props = [scheme_props;  corners.Count/8 im_props.Eccentricity  im_props.Area/im_props.Perimeter^2 scheme_labels(i)];
end

% SCENE shapes prediction
scene_predicted = [];
for i=1:length(scene_props)
    props = scene_props(i,:);
    if(props(1) ~= 0) % check if it actually is a tetromino (has corners)
        if (props(1) == 0.5 || props(1) == 0.75 || props(1) == 1)
            label = predict(classifier_knn, props(1:end-1));       
            scene_predicted = [scene_predicted; props(1:4) str2double(label)];
        end     
    end
end

% SCHEME shapes prediction
scheme_predicted = [];
for i=1:length(scheme_props)
      props = scheme_props(i,:);
      label=predict(classifier_knn,props(1:end-1));
      scheme_predicted = [scheme_predicted; props(1:4) str2double(label)];
end

final_scheme = imschemergb;
% to prevent a piece being used more than once
already_used = false(length(scene_predicted));

for i=1:length(scheme_predicted)    
    for j=1:length(scene_predicted)
        % If scheme shape and scene shape has been classified as the same one 
        if (scheme_predicted(i, 5) == scene_predicted(j, 5) && already_used(j) == false)
            already_used(j) = true;
           
            scene_res_props = regionprops(labeled_scene == scene_predicted(j, 4), "BoundingBox", "MaxFeretProperties");
            scheme_res_props = regionprops(labeled_scheme == scheme_predicted(i, 4), "BoundingBox", "MaxFeretProperties", "Centroid");
                    
            % Scene CROP
            subscene_mask = imcrop(labeled_scene == scene_predicted(j, 4), scene_res_props.BoundingBox);
            subscene_image = imcrop(imscene, scene_res_props.BoundingBox);
            
            % Scheme CROP
            subscheme_mask = imcrop(labeled_scheme == scheme_predicted(i, 4), scheme_res_props.BoundingBox);        
            [final_image, final_mask] = adjust_piece(subscheme_mask, subscene_image, subscene_mask);
            
            piece = color_region(final_image, final_mask);
               
            % TRANSLATION
            % Calculate coordinates offset of the region in which the
            % scheme piece will be placed
            up = round(scheme_res_props.Centroid(2) - size(piece, 1) / 2);
            bottom = round(scheme_res_props.Centroid(2) + size(piece, 1) / 2);
            left = round(scheme_res_props.Centroid(1) - size(piece, 2) / 2);
            right = round(scheme_res_props.Centroid(1) + size(piece, 2) / 2);
            
            % The detected region is multiplied by the inverse of the mask,
            % so that pixels where the piece must be placed will have value
            % 0, and the sorrounding ones remain unchanged
            final_scheme(up:bottom-1, left:right-1, :) = final_scheme(up:bottom-1, left:right-1, :) .* double(1 - final_mask);
            % Since the pixels of the scheme where the piece is to be
            % placed are all 0, it's now enough to sum the piece to the scheme
            final_scheme(up:bottom-1, left:right-1, :) = final_scheme(up:bottom-1, left:right-1, :) + piece;
        
            break;
        end    
    end
end

figure, imshow(final_scheme), title("FINAL IMAGE");