function oldValue = feature( name, optValue )
;%#ok<NOSEM> undocumented
%FEATURE - distcomp-specific features

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/10/12 17:27:34 $

persistent FEATURE_STRUCT

if isempty( FEATURE_STRUCT )
    % Add new features here.

    % Only use MPIEXEC for local scheduler on non-Mac
    shouldUseMpiexec = ~ismac;

    FEATURE_STRUCT = struct( 'LocalUseMpiexec', ...
                             shouldUseMpiexec );
    % Protect persistent data
    mlock;
end

% Get value and return, set if necessary
if isfield( FEATURE_STRUCT, name )
    oldValue = FEATURE_STRUCT.(name);
else
    error( 'distcomp:feature:NoSuchFeature', ...
           'An unknown feature was specified: %s', name );
end

if nargin == 2
    FEATURE_STRUCT.(name) = optValue;
end
