function varargout = wrapRemoteCall( fcnH, varargin )
;%#ok undocumented

% Top-level wrapper for most distributed methods

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/05/14 16:51:34 $

% This may return an exception to throwAsCaller, or empty.
exOrEmpty = iErrCheckArguments( varargin );
if ~isempty( exOrEmpty )
    throwAsCaller( exOrEmpty );
end

varargout = cell( 1, max( nargout, 1 ) );
try
    [varargout{:}] = spmd_feval_fcn( @iInnerWrapper, ...
                                     {fcnH, varargin{:}} ); %#ok<CCAT> - invalid analysis in this case
catch E
    if strcmp( E.identifier, 'distcomp:spmd:RemoteMismatch' )
        throwAsCaller( MException( 'distcomp:distributed:RemoteMismatch', ...
                                   ['You cannot operate on distributed ', ...
                            'arrays which exist on different sets of labs'] ) );
    end
    if strcmp( E.identifier, 'distcomp:distributed:InvalidDistributed' )
        % Should never get here - up front check should have saved us.
        throwAsCaller( MException( 'distcomp:distributed:InvalidDistributed', ...
                                   'An attempt was made to use an invalid distributed array' ) );
    end

    % Re-write exception to show the problem from the labs.
    if ~isempty( E.cause )
        E2 = E.cause{1};
        for ii=2:length( E.cause )
            if ~iTerriblySimilar( E2, E.cause{ii} )
                E2 = addCause( E2, E.cause{ii} );
            end
        end
        throwAsCaller( E2 );
    else
        E2 = MException( 'distcomp:distributed:RemoteFailure', ...
                         'An error was detected during remote execution' );
        E2 = addCause( E2, E );
        throwAsCaller( E2 );
    end
end

% Unpack any AutoDeref objects.
varargout = cellfun( @iUnpackAutoDerefs, varargout, 'UniformOutput', false );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return an exception to be thrown, or empty if no problems detected.
function ex = iErrCheckArguments( argList )
% It is illegal to pass Composites or invalid distributeds to distributed
% methods
ex = [];
for ii = 1:length( argList )
    if isa( argList{ii}, 'Composite' )
        ex = MException( 'distcomp:distributed:IllegalComposite', ...
                         '%s', ... % Always use format specifier
                         ['It is illegal to pass Composite objects as input arguments ', ...
                          'to distributed object methods'] );
        return;
    elseif isa( argList{ii}, 'distributed' )
        d = argList{ii};
        if ~d.isValid()
            ex = MException( 'distcomp:distributed:InvalidDistributed', ...
                             '%s', ... % Always use format specifier
                             ['An attempt was made to use an invalid distributed array. This could be because the ', ...
                              'MATLABPOOL has been closed, or the distributed array could have ', ...
                              'been passed into an SPMD block inside some other container such as ', ...
                              'a cell array or structure'] );
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iTerriblySimilar - do two MExceptions look very similar
function tf = iTerriblySimilar( E1, E2 )
tf = strcmp( E1.identifier, E2.identifier ) && ...
     strcmp( E1.message, E2.message ) ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inner wrapper - called in SPMD context via spmd_feval_fcn
function varargout = iInnerWrapper( fcnH, varargin )
varargout = cell( 1, max( nargout, 1 ) );
[varargout{:}] = fcnH( varargin{:} );

% Wrap any non-codistributed/codistributor objects in a AutoTransfer wrapper.
varargout = cellfun( @iPackNonCodistrAsAutoTransfer, varargout, 'UniformOutput', false );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dereference any AutoDeref objects
function r = iUnpackAutoDerefs( rr )
if isa( rr, 'distributedutil.AutoDeref' )
    r = rr.Value;
else
    r = rr;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turn anything other than codistributed into "AutoTransfer" data - note that
% we do not ever check to see whether the values are in fact replicated.
function r = iPackNonCodistrAsAutoTransfer( rr )
if isa( rr, 'codistributed' )
    r = rr;
else
    r = distributedutil.AutoTransfer( rr );
end
end
