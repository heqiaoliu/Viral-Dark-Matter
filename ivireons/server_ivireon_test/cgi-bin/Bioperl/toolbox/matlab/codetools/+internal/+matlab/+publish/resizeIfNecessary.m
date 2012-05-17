function resizeIfNecessary(imgFilename,imageFormat,imWidth,imHeight)
% Copyright 1984-2009 The MathWorks, Inc.

% Resize the image.
if ~isempty(imHeight) || ~isempty(imWidth)
    switch imageFormat
        case internal.matlab.publish.getVectorFormats
            % Skip it.  PUBLISH throws a warning about this case.
        otherwise
            [myFrame.cdata,myFrame.colormap] = imread(imgFilename);
            internal.matlab.publish.writeImage(imgFilename,imageFormat,myFrame,imHeight,imWidth);
    end
end
end
