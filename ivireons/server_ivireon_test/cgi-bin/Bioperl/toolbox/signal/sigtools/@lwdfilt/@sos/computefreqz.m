function [h, w] = computefreqz(this, N, varargin)
%COMPUTEFREQZ   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:07 $

if nargin < 2
    N = 8192;
end

sosMatrix = get(this, 'sosMatrix');
scales    = get(this, 'ScaleValues');

[h, w] = freqz(sosMatrix(1,1:3), sosMatrix(1,4:6), N, varargin{:});
for indx = 2:size(sosMatrix, 1)
    h = h.*freqz(sosMatrix(indx,1:3), sosMatrix(indx,4:6), N, varargin{:});    
end

h = h*prod(scales);

% [EOF]
