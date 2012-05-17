function [Ht, anum, aden] = iirxform(Ho, fun, varargin)
%IIRXFORM IIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:57:12 $

% This should be private

[b, a] = tf(Ho);

[num, den, anum, aden] = feval(fun, b, a, varargin{:});

% Create the transformed and allpass filters
Ht  = dfilt.df2(num, den);

% [EOF]
