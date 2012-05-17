function newData = padArray(oldData, padValue, newSize)
%PADARRAY Pad an array

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:54 $

nOldDims  = ndims(oldData);
dataIndex = cell(1, nOldDims);

% Get the indices into the original data that we will assign into the
% padded array.
for indx = 1:nOldDims
    dataIndex{indx} = 1:size(oldData, indx);
end

% Build the new data with the pad value and the new size.
newData = repmat(padValue, newSize);

% Put the old data into the new data using the indices built earlier/
newData(dataIndex{:}) = oldData;

% [EOF]
