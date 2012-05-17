function s = isdistributed( ~ )
%ISDISTRIBUTED   True for a distributed array
%   TF = ISDISTRIBUTED(X) returns true for a distributed array and
%   false otherwise.
%
%   Example:
%     N = 1000;
%     D = distributed.ones( N );
%     t = isdistributed( D ) % returns t = true
%     f = isdistributed( N ) % returns f = false
%
%   See also DISTRIBUTED, CODISTRIBUTED, ISCODISTRIBUTED, ISREPLICATED.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/04/15 22:59:23 $

s = false;
end
