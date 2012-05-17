function [S, T] = computestepz(this, varargin)
%COMPUTESTEPZ   

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:12 $

[I, T] = computeimpz(this, varargin{:});

S = cumsum(I);

% [EOF]
