function [hz, wz, phiz, opts] = computezerophase(this, N, varargin)
%COMPUTEZEROPHASE

%   Author: V. Pellissier, J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:45:07 $

% This should be private

if nargin < 2
    N = 8192;
end

[hz,wz,phiz,opts] = zerophase(this.Numerator,1,N,varargin{:});

% [EOF]
