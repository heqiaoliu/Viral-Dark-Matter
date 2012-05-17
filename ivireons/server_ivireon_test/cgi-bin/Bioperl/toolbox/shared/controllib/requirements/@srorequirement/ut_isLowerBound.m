function lowerBound = ut_isLowerBound(Req) 
% UT_ISLOWERBOUND returns lowerbound state of requirement
%
% Static package method so that some requirement sub-classes classes can use
% the same implementation. Cannot be a parent method because of heterogeneous
% arrays, when isLowerBound check may not be consistent across all types.
 
% Author(s): A. Stothert 05-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:23 $

nReq = numel(Req);
lowerBound = false(size(Req));
for ct=1:nReq
    lowerBound(ct) = strncmpi(Req(ct).getData('Type'),'lower',5);
end