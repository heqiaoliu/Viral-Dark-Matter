function maxDimensions = getMaxDimensions(this, ~)
%GETMAXDIMENSIONS Get the maxDimensions.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:08:00 $

userData = this.DataHandler.UserData;

if isstruct(userData)
    userData = userData(1).cdata;
end

maxDimensions = size(userData);

timeDimension = getTimeDimension(this.DataHandler);

if size(maxDimensions, 2) == timeDimension

    % Remove the time dimension
    if numel(maxDimensions) == 2
        maxDimensions(end) = 1;
    elseif maxDimensions(end) > 1
        maxDimensions(end) = [];
    end
end

% [EOF]
