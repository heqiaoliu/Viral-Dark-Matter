function t = and(A,B)
%&      Logical AND
%   Refer to the MATLAB AND reference page for more information.
% 
%   See also AND

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:11:52 $

error(nargchk(2,2,nargin,'struct'))

t = (A~=0) & (B~=0);
