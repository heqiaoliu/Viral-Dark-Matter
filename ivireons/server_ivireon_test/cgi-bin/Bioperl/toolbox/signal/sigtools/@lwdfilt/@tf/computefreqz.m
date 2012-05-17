function [H, W] = freqz(this, N, varargin)
%FREQZ   Calculate the frequency response of the filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:23 $

if nargin < 2
    N = 8192;
end

[H, W] = freqz(this.Numerator, this.Denominator, N, varargin{:});

% [EOF]
