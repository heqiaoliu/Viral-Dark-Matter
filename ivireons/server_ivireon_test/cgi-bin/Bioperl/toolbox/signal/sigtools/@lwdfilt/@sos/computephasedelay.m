function [Ph, W] = computephasedelay(this,N,varargin)
%COMPUTEPHASEDELAY   Calculate the phase delay of the filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:17:33 $

if nargin < 2
    N = 8192;
end

sosMatrix = get(this, 'sosMatrix');

[Ph, W] = phasedelay(sosMatrix(1,1:3), sosMatrix(1,4:6), N, varargin{:});
for indx = 2:size(sosMatrix, 1)
    Ph = Ph + phasedelay(sosMatrix(indx,1:3), sosMatrix(indx,4:6), N, varargin{:});    
end


% [EOF]
