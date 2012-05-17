function flag = issingle(h)
%ISSINGLE   True for states which are single.
%   ISSINGLE(H) returns true if H is a DFILT.DFIIRSTATES object whose
%   Numerator and Denominator states are single and false otherwise. 

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:17 $

flag = isa(h.Numerator,'single') && isa(h.Denominator,'single');
    
% [EOF]
