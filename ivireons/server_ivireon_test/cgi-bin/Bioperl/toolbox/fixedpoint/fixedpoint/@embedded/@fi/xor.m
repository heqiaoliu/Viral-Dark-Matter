function t = xor(A,B)
%XOR Logical EXCLUSIVE OR
%   Refer to the MATLAB XOR reference page for more information.
%
%   See also XOR 

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:13:09 $

error(nargchk(2,2,nargin,'struct'))

t = xor(A~=0, B~=0);
