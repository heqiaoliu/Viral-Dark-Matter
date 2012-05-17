function Ht = firxform(Ho,fun,varargin)
%FIRXFORM FIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:56:51 $

[b, a] = tf(reffilter(Ho));

num = feval(fun, b, varargin{:});

% Create the transformed filter
Ht = copy(Ho);
arith = Ht.Arithmetic; % Cache setting
Ht.Arithmetic = 'double';
Ht.Numerator = num;
Ht.Arithmetic = arith; % Reset arithmetic


% [EOF]
