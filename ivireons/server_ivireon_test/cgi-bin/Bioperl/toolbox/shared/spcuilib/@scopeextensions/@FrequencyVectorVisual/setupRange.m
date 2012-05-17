function setupRange(this)
%SETUPRANGE Setup the Range

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:48 $

switch getPropValue(this, 'FrequencyRange')
    case '[-Fs/2...Fs/2]'
        this.RangeIndex = 2;
        this.XTransformFcn = @(in) convertToCenterDC(in);
    case '[0...Fs/2]'
        this.RangeIndex = 1;
        this.XTransformFcn = @(in) in(1:floor(size(in, 1)/2), :);
    case '[0...Fs]'
        this.RangeIndex = 3;
        this.XTransformFcn = [];
end

% -------------------------------------------------------------------------
function out = convertToCenterDC(in)

nrows = size(in, 1);
p = ceil(nrows/2);
out = in([p+1:nrows 1:p],:);

% [EOF]
