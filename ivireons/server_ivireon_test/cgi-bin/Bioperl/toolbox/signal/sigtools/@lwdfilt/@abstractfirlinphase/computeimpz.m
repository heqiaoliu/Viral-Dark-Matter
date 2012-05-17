function [I, T] = impz(this, varargin)
%IMPZ   Calculate the impulse response.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:19:57 $

[I, T] = impz(this.Numerator, 1, varargin{:});

% [EOF]
