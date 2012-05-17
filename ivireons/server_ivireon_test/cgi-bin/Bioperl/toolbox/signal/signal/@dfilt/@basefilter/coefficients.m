function C = coefficients(Hb)
%COEFFICIENTS Filter coefficients.
%   C = COEFFICIENTS(Hb) returns a cell array of coefficients of
%   discrete-time filter Hb.
% 
%   COEFFICIENTS(Hm) with no output argument displays the coefficients.
%
%   See also DFILT.   

%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2005/02/23 02:47:53 $

if nargout,
    C = thiscoefficients(Hb);
else
    disp(dispstr(Hb));
end

% [EOF]
