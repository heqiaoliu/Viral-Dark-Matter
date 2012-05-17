function t = or(A,B)
%OR     Logical OR
%   Refer to the MATLAB OR reference page for more details.
%
%   See also OR

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:40 $

error(nargchk(2,2,nargin,'struct'))

t = (A~=0) | (B~=0);
