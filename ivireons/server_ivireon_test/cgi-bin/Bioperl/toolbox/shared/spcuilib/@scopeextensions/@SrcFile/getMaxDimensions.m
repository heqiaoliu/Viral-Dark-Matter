function maxDimensions = getMaxDimensions(this, ~)
%GETMAXDIMENSIONS Get the maxDimensions.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:49 $

maxDimensions = this.Data.Dimensions;

if strcmp(this.Data.ColorSpace, 'rgb')
    maxDimensions = [maxDimensions 3];
end

% [EOF]
