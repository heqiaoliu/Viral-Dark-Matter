function r = mtimes(p,q)
% CVDATA/PLUS   Implement P*Q, data intersection.
%
% When a test metric exists in only one of
% the arguments, the intersection will be empty.
%
% DECISION The path counts are the minimum of the
% count in P and the count in Q and the aggregate counts 
% are calculated from the minimum.
%
% CONDITION The condition evaluation counts are 
% the sum of the counts in P and Q and the aggregate
% counts are the aggregate of the sum.
%
% RELATION The equality counts are the sum of the 
% counts in P and Q and the aggregate counts are the 
% aggregate of the sum.  The min positive difference 
% is the minimum from P and Q, and the max negative
% difference is the max from P and Q.

% 	Bill Aldrich
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/01 08:00:04 $

r = times(p,q);   
