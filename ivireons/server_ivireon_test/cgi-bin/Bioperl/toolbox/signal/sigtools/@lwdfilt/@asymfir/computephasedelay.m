function [P, W] = computephasedelay(this, N, varargin)
%PHASEDELAY   Calculate the phase delay.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:31 $

if nargin < 2
    N = 8192;
end

[P, W] = phasedelay(this.Numerator, 1, N, varargin{:});


% [EOF]
