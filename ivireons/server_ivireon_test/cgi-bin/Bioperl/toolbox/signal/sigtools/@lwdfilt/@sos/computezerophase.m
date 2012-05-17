function [hz, wz, phiz, opts] = computezerophase(this, N, varargin)
%COMPUTEZEROPHASE

%   Author: V. Pellissier, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/02/23 02:54:50 $

% This should be private

if nargin < 2
    N = 8192;
end

sosMatrix = get(this, 'sosMatrix');
scales    = get(this, 'ScaleValues');

[hz,wz,phiz,opts] = zerophase(sosMatrix(1,1:3), sosMatrix(1,4:6), N, varargin{:});
for indx = 2:size(sosMatrix, 1),
    [h,w,phi] = zerophase(sosMatrix(indx,1:3), sosMatrix(indx,4:6), N, varargin{:});
    hz = hz.*h;
    phiz = phiz+phi;
end

hz = hz*prod(scales);

% [EOF]
