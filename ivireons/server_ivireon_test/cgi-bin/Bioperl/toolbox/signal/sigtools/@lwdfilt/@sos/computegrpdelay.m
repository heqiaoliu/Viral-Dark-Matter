function [Gd, w] = computegrpdelay(this, N, varargin)
%COMPUTEGRPDELAY   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:08 $

if nargin < 2
    N = 8192;
end

sosMatrix = get(this, 'sosMatrix');

[Gd, w] = grpdelay(sosMatrix(1,1:3), sosMatrix(1,4:6), N, varargin{:});
for indx = 2:size(sosMatrix, 1)
    Gd = Gd + grpdelay(sosMatrix(indx,1:3), sosMatrix(indx,4:6), N, varargin{:});    
end

% [EOF]
