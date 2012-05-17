function flag = isdouble(h)
%ISDOUBLE   True for states which are double.
%   ISDOUBLE(H) returns true if H is a DFILT.DFIIRSTATES object whose
%   Numerator and Denominator states are double and false otherwise. 

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:12 $

flag = isa(h.Numerator,'double') && isa(h.Denominator,'double');
    
% [EOF]
