function varargout = subsref( obj, S )
%SUBSREF Subscripted reference for distributed array
%   B = A(I)
%   B = A(I,J)
%   B = A(I,J,K,...)
%   
%   The index I in A(I) must be :, scalar or a vector.
%   
%   A{...} indexing is not supported for distributed cell arrays.
%   A.field indexing is not supported for distributed arrays of structs.
%   
%   Example:
%       N = 1000;
%       D = distributed.eye(N);
%       one = D(N,N)
%   
%   See also SUBSREF, DISTRIBUTED, DISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $   $Date: 2009/05/14 16:51:43 $

% Because of the way MATLAB translates index requests into subsref calls, S
% may contain distributed objects, so we need to disentangle things.

if length( S ) ~= 1
    error( 'distcomp:distributed:DistributedSubsref', ...
           'Distributed objects only support simple subscripting' );
end

% Must check here to avoid calling codistributed/subsref with too many
% output arguments.
if ~isequal( S(1).type, '()' )
    error( 'distcomp:distributed:DistributedSubsref', ...
           'Distributed SUBSREF currently only supports () indexing' );
end

% We must pass the subs in explicitly, as some of them might be
% distributed. wrapRemoteCall will check for validity of any distributed
% arguments.
[varargout{1:nargout}] = wrapRemoteCall( @iSubsRefHelper, obj, S.type, S.subs{:} );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receives the disentangled index information which
function varargout = iSubsRefHelper( coDd, s_type, varargin )
varargout = cell( 1, nargout );
[varargout{:}] = subsref( coDd, substruct( s_type, varargin ) );
end
