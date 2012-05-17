function [S, T] = stepz(this, varargin)
%STEPZ   Calculate the step response.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:19:59 $

[S, T] = stepz(this.Numerator, 1, varargin{:});

% [EOF]
