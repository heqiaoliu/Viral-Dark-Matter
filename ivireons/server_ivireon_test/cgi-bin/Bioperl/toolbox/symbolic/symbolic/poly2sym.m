function p = poly2sym(c,x)
%POLY2SYM Polynomial coefficient vector to symbolic polynomial.
%   POLY2SYM(C) is a symbolic polynomial in 'x' with coefficients
%   from the vector C.
%   POLY2SYM(C,'V') and POLY2SYM(C,SYM('V') both use the symbolic
%   variable specified by the second argument.
% 
%   Example:
%       poly2sym([1 0 -2 -5])
%   is
%       x^3-2*x-5
%
%       poly2sym([1 0 -2 -5],'t')
%   and
%       t = sym('t')
%       poly2sym([1 0 -2 -5],t)
%   both return
%       t^3-2*t-5
%
%   See also SYM/SYM2POLY, POLYVAL.

%   Copyright 1993-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 20:41:45 $

if nargin < 2, x = 'x'; end
p = poly2sym(sym(c),sym(x));
