function lowerBound = isLowerBound(this) 
% ISLOWERBOUND returns lowerbound state of requirement
%
 
% Author(s): A. Stothert 11-Dec-2007
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:22 $

nReq = numel(this);
lowerBound = false(size(this));
for ct=1:nReq
    lowerBound(ct) = this(ct).isLowerBound;
end