function Ht = firxform(Ho,fun,varargin)
%FIRXFORM FIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:57:56 $

[b, a] = tf(Ho);

num = feval(fun, b, varargin{:});

Ht = feval(str2func(class(Ho)), num);

% [EOF]
