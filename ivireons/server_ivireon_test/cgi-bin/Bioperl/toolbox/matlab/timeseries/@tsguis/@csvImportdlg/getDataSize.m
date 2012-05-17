function rowLength = getDataSize(h,dim)

% Copyright 2006 The MathWorks, Inc.

%% Get the number of columns for the current sheet
rowLength = size(h.IOData.rawdata,dim);
