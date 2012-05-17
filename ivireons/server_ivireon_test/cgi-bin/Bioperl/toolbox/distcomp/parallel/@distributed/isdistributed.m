function tf = isdistributed( obj )
%ISDISTRIBUTED True for a distributed array
%   TF = ISDISTRIBUTED( X ) returns true for a distributed array and false
%   otherwise
%   
%   Example:
%     N = 1000;
%     D = distributed.ones( N );
%     t = isdistributed( D ) % returns t = true
%     f = isdistributed( N ) % returns f = false
%   
%   See also DISTRIBUTED, CODISTRIBUTED, ISCODISTRIBUTED, ISREPLICATED.
%   


%   Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/05/14 16:51:40 $

% Protect against broken distributed.
errorIfInvalid( obj );

tf = true;
end
