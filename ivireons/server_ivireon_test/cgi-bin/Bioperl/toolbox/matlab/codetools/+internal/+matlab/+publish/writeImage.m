function writeImage(imgFilename,imageFormat,myFrame,imHeight,imWidth)

% Copyright 1984-2009 The MathWorks, Inc.

x = myFrame.cdata;
map = myFrame.colormap;

[height,width,null] = size(x);  %#ok<NASGU> Removing 3rd argument changes behavior of SIZE.
if ~isempty(imHeight) && (height > imHeight) || ...
        ~isempty(imWidth) && (width > imWidth)
    if ~isempty(map)
        % Convert indexed images to RGB before resizing.
        x = ind2rgb(x,map);
        map = [];
    end
    if ~isempty(imHeight) && (height > imHeight)
        width = width*(imHeight/height);
        height = imHeight;
    end
    if ~isempty(imWidth) && (width > imWidth)
        height = height*(imWidth/width);
        width = imWidth;
    end
    if isequal(class(x),'double')
        x = uint8(floor(x*255));
    end
    x = internal.matlab.publish.make_thumbnail(x,floor([height width]));
end

if isempty(map)
    imwrite(x,imgFilename,imageFormat);
else
    imwrite(x,map,imgFilename,imageFormat);
end
end

