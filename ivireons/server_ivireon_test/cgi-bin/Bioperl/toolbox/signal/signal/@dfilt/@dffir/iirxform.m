function [Ht, anum, aden] = iirxform(Ho, fun, varargin)
%IIRXFORM IIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:55:38 $

% This should be private

[b, a] = tf(reffilter(Ho));

[num, den, anum, aden] = feval(fun, b, a, varargin{:});

% Create the transformed and allpass filters
Ht  = dfilt.df2(num, den);

% [EOF]
