function Ht = firxform(Ho,fun,varargin)
%FIRXFORM FIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:57:11 $

[b, a] = tf(Ho);

num = feval(fun, b, varargin{:});

Ht = copy(Ho);
Ht.Numerator = num;

% [EOF]
