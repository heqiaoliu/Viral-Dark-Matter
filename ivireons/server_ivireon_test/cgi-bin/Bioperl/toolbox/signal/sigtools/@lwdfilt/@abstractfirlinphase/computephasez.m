function [P, W] = phasez(this, N, varargin)
%PHASEZ   Return the phase response.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:19:58 $

if nargin < 2
    N = 8192;
end

[P, W] = phasez(this.Numerator, 1, N, varargin{:});


% [EOF]
