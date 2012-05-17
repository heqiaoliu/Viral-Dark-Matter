function flag = isempty(A)
%ISEMPTY True for empty codistributed array
%   TF = ISEMPTY(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N,0,N);
%       t = isempty(D)
%   end
%   
%   returns t = true.
%   
%   See also ISEMPTY, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:58:41 $

flag = ~all(size(A));
