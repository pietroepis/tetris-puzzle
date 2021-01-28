% Reduces image to minimum bounding box, to remove black frames

function out = remove_border(image)
   props = regionprops(image, "BoundingBox");
   out = imcrop(image, props.BoundingBox);
end
