function obj = subsasgn( obj, S, value )
%SUBSASGN Subscripted assignment for distributed array
%   A(I) = B
%   A(I,J) = B for 2D distributed arrays
%   A(I1,I2,I3,...,IN) = B for ND distributed arrays
%   
%   A{...} indexing is not supported for distributed cell arrays.
%   A.field indexing is not supported for distributed arrays of structs.
%   
%   To expand an ND distributed array A to higher dimensions via
%   A(I1,I2,...IN,IN+1) = B, B must be a scalar.
%   
%   A(I) = B cannot be used to expand the size of A.
%   
%   Example:
%       N = 1000;
%       D = distributed.eye(N);
%       D(1,N) = pi
%   
%   See also SUBSASGN, DISTRIBUTED, DISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $   $Date: 2009/05/14 16:51:42 $

if isempty( obj )
    % First check - ensure we're not doing something like x(3) = d where x
    % doesn't currently exist
    % TODO: remove this!
    error( 'distcomp:spmd:DistributedSubsasgn', ...
           'You cannot create an array by indexed assignment from a distributed object' );
end

if length( S ) ~= 1
    error( 'distcomp:distributed:DistributedSubsref', ...
           'Distributed objects only support simple subscripting' );
end

% Disentangle the subs in case they contain any distributed
% objects. wrapRemoteCall will check for validity of any distributed
% arguments.
obj = wrapRemoteCall( @iSubsAsgnHelper, obj, S.type, value, S.subs{:} );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper to re-create the substruct and apply it as appropriate
function coDd = iSubsAsgnHelper( coDd, sType, value, varargin )
coDd = subsasgn( coDd, substruct( sType, varargin ), value );
end
