function varargout = dload( varargin )
%DLOAD Load distributed arrays and Composites from disk
%   DLOAD FILENAME retrieves all variables from a file given a full
%   pathname or a MATLABPATH relative partial pathname (see PARTIALPATH). If
%   FILENAME has no extension, DLOAD looks for
%   FILENAME.mat. DLOAD loads the contents of distributed arrays
%   and Composite objects onto MATLABPOOL workers, other data types are
%   loaded directly into the workspace of the MATLAB client.
%
%   DLOAD, by itself, uses the binary "MAT-file" named
%   "matlab.mat". It is an error if "matlab.mat" is not found.
%
%   DLOAD FILENAME X loads only X. DLOAD FILENAME X Y Z ...  
%   loads just the specified variables. DLOAD does not support wildcards or
%   the "-regexp" option. If any requested variable is not present in the
%   file, a warning is issued.
%
%   DLOAD -SCATTER ... distributes non-distributed data where
%   possible. If the data cannot be distributed, a warning is issued.
%
%   [X, Y, Z, ...] = DLOAD( 'FILENAME', 'X', 'Y', 'Z', ... ) returns the
%   specified variables as separate output arguments (rather than as a
%   structure, which the load function returns). If any requested variable
%   is not present in the file, an error is issued.
%
%   When loading distributed arrays, the data will be distributed over the
%   available MATLABPOOL workers using the default distribution scheme. It
%   is not necessary to have the same size MATLABPOOL open when loading as
%   when saving using DSAVE. 
%
%   When loading Composite objects, the data will be sent to the available
%   MATLABPOOL workers. If the Composite is too large to fit on the current
%   MATLABPOOL, the data will not be loaded. If the Composite is smaller
%   than the current MATLABPOOL, a warning will be issued.
%
%   Example:
%   dload fname x y z % loads x, y, and z from fname.mat
%   [p, q] = dload( 'fname.mat', 'p', 'q' ); % return 'p' and 'q' explicitly.
%
%   See also DSAVE, DISTRIBUTED, COMPOSITE, MATLABPOOL.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/12/03 19:00:33 $

try
    % Prelude - process args, make sure we can read the file
    [userFname, printFname, userOptions, userVarNames] = ...
        distributedutil.DsaveDloadParser.parseOptions( ...
            'dload', varargin, {'-scatter'} );
    dmatFile   = distributedutil.DmatFile.openForRead( userFname );
    % When checking vars, need to know whether we're being asked for output
    % arguments. iCheckVars will either error or warn on missing variables.
    shouldErrorOnMissingVars = ( nargout > 0 );
    varsToLoad = iCheckVars( dmatFile, userVarNames, shouldErrorOnMissingVars );
    doScatter  = ismember( '-scatter', userOptions );
catch E
    % Strip stack
    throw( E );
end

% Check nargout - either zero or length of "varsToLoad" are the only
% acceptable options.
if nargout > 0 && nargout ~= length( varsToLoad )
    error( 'distcomp:dload:NumberOfOutputArguments', ...
           ['When DLOAD is used with output arguments, the number of output ', ...
            'arguments must match the number of variables requested: %d ', ...
            'variable(s) were requested, %d output argument(s) were supplied.'], ...
           length( varsToLoad ), nargout );
end

if printFname
    % Get here with no arguments at all - mimic load, and print the default name.
    fprintf( 1, 'Loading from: %s\n', dmatFile.FileName );
end

% Pre-allocate a struct with no fields.
result = struct;

for ii=1:length( varsToLoad )
    try
        % Stuff things into result, we'll push up to the caller workspace later if
        % required.
        result.(varsToLoad{ii}) = iLoadOne( dmatFile, varsToLoad{ii}, doScatter );
    catch E
        EE = MException( 'distcomp:dload:ErrorLoadingVariable', ...
                         'An error occurred loading "%s" from %s, this array has not been loaded.', ...
                         varsToLoad{ii}, dmatFile.FileName );
        EE = addCause( EE, E );
        throw( EE );
    end
end

if nargout == 0
    for ii = 1:length( varsToLoad )
        try
            assignin( 'caller', varsToLoad{ii}, result.(varsToLoad{ii}) );
        catch E
            if isequal( E.identifier, 'MATLAB:err_static_workspace_violation' )
                % Transparency / static workspace violation - possibly called "DSAVE" within
                % an SPMD block
                error( 'distcomp:dload:TransparencyViolation', ....
                       ['A transparency violation error occurred during DLOAD. This ', ...
                        'might be caused by calling DLOAD directly within an SPMD block.'] );
            else
                rethrow( E );
            end
        end
    end
else
    varargout = cell( 1, length( varsToLoad ) );
    for ii=1:length( varsToLoad )
        varargout{ii} = result.(varsToLoad{ii});
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part of the argument checking - if the user didn't specify explicitly
% which variables to load, return all the variables in the file; otherwise,
% check that the specified variables exist in the file.
function varsToLoad = iCheckVars( dmatFile, userVarNames, shouldErrorOnMissingVars )

if isempty( userVarNames )
    varsToLoad = dmatFile.getVariableNames();
else
    namesInFile = dmatFile.getVariableNames();
    missingVars = setdiff( userVarNames, namesInFile );
    if ~isempty( missingVars )
        missingVarsStr = strtrim( sprintf( '%s ', missingVars{:} ) );
        if shouldErrorOnMissingVars
            fcnh = @error;
        else
            fcnh = @warning;
        end
        fcnh( 'distcomp:dload:MissingVariables', ...
              'The following variables cannot be found in %s: %s.', ...
              dmatFile.FileName, missingVarsStr );
        varsToLoad = intersect( userVarNames, namesInFile );
    else
        varsToLoad = userVarNames;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load a single entry from the file - using one of the known loaders.
function v = iLoadOne( dmatFile, varName, doScatter )

[infoStruct, supportsPartial] = dmatFile.getVariableMetadata( varName );

% May not be in possession of a template if none can be extracted, defend
% against that.
switch infoStruct.Type
  case 'distributed'
    % Assume supportsPartial is true.
    v = iLoadDistributed( dmatFile, varName, infoStruct );
  case 'Composite'
    % Assume supportsPartial is true.
    v = iLoadComposite( dmatFile, varName, infoStruct );
  case 'data'
    if supportsPartial && doScatter
        % Can do partial loads straight into distributed
        v = iLoadNormalWithScatter( dmatFile, varName, infoStruct );
    else
        % No partial loading, load full variable.
        v = iLoadNormal( dmatFile, varName );
        if doScatter
            v = iScatterIfPossible( v, varName );
        end
    end
  otherwise
    error( 'distcomp:dload:UnknownType', ...
           'An unknown type (%s) of variable was found in the file: %s.', ...
           dmatFile.FileName, infoStruct.Type );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load a single composite from the file. 
function c = iLoadComposite( dmatFile, varName, infoStruct )

existFlag     = infoStruct.Info.Exist;
desiredLength = length( existFlag );

c = Composite();
if length( c ) < desiredLength
    error( 'distcomp:dload:BadCompositeLength', ...
           ['The Composite "%s" was created with a pool of size %d, and cannot be loaded ', ...
            'into a Composite of size %d (the current default Composite size).'], ...
           varName, desiredLength, length( c ) );
end
if desiredLength < length( c )
    warning( 'distcomp:dload:BadCompositeLength', ...
             ['The Composite "%s" was created with a pool of size %d, and is being loaded ', ...
              'into a Composite of size %d (the current default Composite size).'], ...
             varName, desiredLength, length( c ) );
end

for ii = 1:length( existFlag )
    if existFlag(ii)
        regionStruct = struct( 'start', [1; ii], ...
                               'end', [1; ii] );
        data = dmatFile.readVariableRegion( varName, regionStruct );
        % Send the data to that lab
        c( ii ) = data;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert to distributed if possible, otherwise warn
function v = iScatterIfPossible( v, varName )
if distributedutil.Allocator.supportsCreation( v )
    % Scatter simply by using the cast constructor. Without partial MAT-file
    % loading, this is the best we can do.
    v = distributed( v );
else
    warning( 'distcomp:dload:CannotScatterVariable', ...
             ['Could not scatter "%s" because the type (%s) is not supported for ', ...
              'distributed array creation.'], varName, class( v ) );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a variable that was saved as a normal variable, and scatter it as
% we go because we can do partial reads.
function v = iLoadNormalWithScatter( dmatFile, varName, infoStruct )

% Start by reading the first element from the file to see if we can
% scatter.
fullSz = infoStruct.Size;
fullNumel = prod( fullSz );
if fullNumel == 0
    % No elements in the file, can't load just one of them - so load the full
    % variable and scatter.
    v = iLoadNormal( dmatFile, varName );
    v = iScatterIfPossible( v, varName );
    return;
end

% We know that we have multiple elements, so can load one of them.
firstElRegion = struct( 'start', ones( length( fullSz ), 1 ), ...
                        'end', ones( length( fullSz ), 1 ) );
tmpl = dmatFile.readVariableRegion( varName, firstElRegion );

if distributedutil.Allocator.supportsCreation( tmpl )
    v = iReadDistributed( dmatFile, fullSz, tmpl, varName );
else
    v = iLoadNormal( dmatFile, varName );
    warning( 'distcomp:dload:CannotScatterVariable', ...
             ['Could not scatter "%s" because the type (%s) is not supported for ', ...
              'distributed array creation.'], varName, class( v ) );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Method shared by iLoadDistributed and iLoadNormalWithScatter when it has
% been determined that we need to create and fill a distributed array.
function D = iReadDistributed( dmatFile, fullSz, tmpl, varName )
D = spmd_feval_fcn( @distributedutil.Allocator.createCodistributed, { fullSz, tmpl } );
% Build the region iterator
regionIt = distributedutil.DistributedRegionIterator( D );

while regionIt.hasMoreRegions()
    region = regionIt.nextRegion();
    data   = dmatFile.readVariableRegion( varName, region );
    D      = hSendData( D, region, data );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a single normal variable from the file
function v = iLoadNormal( dmatFile, varName )
v = dmatFile.readCompleteVariable( varName );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a distributed entry from the file by reading a chunk at a time, and
% sending it out to the labs.
function v = iLoadDistributed( dmatFile, varName, infoStruct )

tmpl     = infoStruct.Info.Template;
fullSize = infoStruct.Size;
v        = iReadDistributed( dmatFile, fullSize, tmpl, varName );
end
