function y = gcat(x,d, labTarget)
%GCAT   Global concatenation
%   Y = GCAT(X) concatenates the variant arrays X from each lab in the
%   second dimension. The result is replicated on all labs.
%
%   Y = GCAT(X,DIM) concatenates the variant arrays X from each lab in
%   the d-th dimension.
%
%   Y = GCAT(X, DIM, LABTARGET) places all of the results on lab LABTARGET.
%   Y will be equal to [] on all other labs.
%
%   Example
%   With a matlabpool of size 4
%
%   spmd
%      y = gcat(labindex)
%   end
%
%   returns y = [1 2 3 4] on all 4 labs.
%
%   See also GOP, CAT, LABINDEX, NUMLABS.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/02/25 08:02:13 $

if nargin < 2, d = 2; end
if nargin <= 2
    y = gop(@(x,y) cat(d,x,y), x);
elseif nargin == 3
    y = gop(@(x,y) cat(d,x,y), x, labTarget);
end

