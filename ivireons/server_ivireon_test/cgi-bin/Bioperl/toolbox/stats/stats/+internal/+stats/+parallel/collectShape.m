function shapeParameters = collectShape(shapeParameters, slice)
%COLLECTSHAPE collects dimensioning info for SMARTFOR sliced outputs.
%
%   COLLECTSHAPE is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

for i=1:length(slice)
    shapeParameters{i} = size(slice{i});
end

