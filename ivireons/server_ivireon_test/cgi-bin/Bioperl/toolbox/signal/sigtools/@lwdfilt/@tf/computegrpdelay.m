function [G, W] = grpdelay(this, N, varargin)
%GRPDELAY   Calculate the group delay.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:24 $

if nargin < 2
    N = 8192;
end

[G, W] = grpdelay(this.Numerator, this.Denominator, N, varargin{:});

% [EOF]
