function y = gplus(x, labTarget)
%GPLUS   Global addition
%   Y = GPLUS(X) returns the addition of the X's from each lab.
%   The result is replicated on all labs.
%
%   Y = GPLUS(X, LABTARGET) places all of the results on lab LABTARGET. Y
%   will be equal to [] on all other labs.
%
%   Example
%   With a matlabpool of size 4
%
%   spmd
%      y = gplus(labindex)
%   end
%
%   returns y = 1+2+3+4=10 on all 4 labs.
%
%   See also GOP, PLUS, LABINDEX.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/02/25 08:02:15 $
if nargin == 1
    y = gop(@plus,x);
elseif nargin == 2
    y = gop(@plus, x, labTarget);
end
