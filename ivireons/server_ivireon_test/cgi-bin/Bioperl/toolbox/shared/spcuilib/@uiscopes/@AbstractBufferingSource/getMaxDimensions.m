function maxDimensions = getMaxDimensions(this, indx)
%GETMAXDIMENSIONS Get the maxDimensions.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:41 $

maxDimensions = this.MaxDimensions;

if isempty(maxDimensions)
    maxDimensions = [0 0];
elseif nargin > 1
    maxDimensions = maxDimensions(indx, :);
    
    if numel(maxDimensions) > 2
        postDims = maxDimensions(3:end);
        
        % Remove any trailing ones.
        postDims = postDims(1:find(postDims ~= 1, 1, 'last'));
        maxDimensions = [maxDimensions(1:2) postDims];
    end
end

% [EOF]
