function c = set_coeffs(this,c)                                               
%SET_COEFFS Set the coefficients.                                          

%   Author(s): V. Pellissier                                          
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:09:46 $                                               


error(nargchk(2,2,nargin,'struct'));                                                

% Always store as a row                                                    
c = c(:).';                                                                

clearmetadata(this);

% [EOF]
