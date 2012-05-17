function len = length(A)
%LENGTH Length of codistributed vector
%   L = LENGTH(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(0,N,0);
%       l = length(D)
%   end
%   
%   returns l = 0.
%   
%   See also LENGTH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:58:51 $

s = size(A);
if any(s == 0)
   len = 0;
else
   len = max(s);
end
