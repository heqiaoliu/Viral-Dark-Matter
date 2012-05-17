function [P, W] = phasedelay(this, N, varargin)
%PHASEDELAY   Calculate the phase delay.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:26 $

if nargin < 2
    N = 8192;
end

[P, W] = phasedelay(this.Numerator, this.Denominator, N, varargin{:});


% [EOF]
