function dsave( varargin )
%DSAVE Save workspace distributed arrays and Composite objects to disk
%   DSAVE FILENAME saves all workspace variables including distributed
%   arrays and Composite objects to the binary "MAT-file" named
%   FILENAME.mat. The data may be retrieved with DLOAD. If FILENAME has no
%   extension, .mat is assumed.
%
%   DSAVE, by itself, creates the binary "DMAT-file" named "matlab.mat".
%
%   DSAVE FILENAME X saves only X.
%
%   DSAVE FILENAME X Y Z saves X, Y, and Z. DSAVE does not
%   support wildcards or the "-regexp" option.
%
%   DSAVE does not support saving sparse distributed arrays. 
%
%   Example:
%   D = distributed.rand( 1000 );
%   C = Composite();
%   C{1} = magic( 20 );
%   X = rand( 40 );
%   dsave mydatafile D C X
%
%   See also DLOAD, DISTRIBUTED, COMPOSITE, MATLABPOOL.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/11/07 20:52:14 $

% Arg processing - figure out who we're trying to save, and any other
% arguments
try
    allNames = evalin( 'caller', 'who' );
catch E
    if isequal( E.identifier, 'MATLAB:err_transparency_violation' )
        % Transparency - probably called "DSAVE" within an SPMD block
        error( 'distcomp:dsave:TransparencyViolation', ....
               ['A transparency violation error occurred during DSAVE. This ', ...
                'might be caused by calling DSAVE directly within an SPMD block.'] );
    else
        rethrow( E );
    end
end

try
    allowedOptions = {}; % No options for DSAVE.
    [userFname, tellUserFilename, ~, userVarNames] = distributedutil.DsaveDloadParser.parseOptions( ...
        'dsave', varargin, allowedOptions );
catch E
    % Strip stack
    throw( E );
end

if ~isempty( userVarNames )
    missingVars = setdiff( userVarNames, allNames );
    if ~isempty( missingVars )
        error( 'distcomp:dsave:MissingVariables', ...
               'The following variables could not be found for DSAVE: %s', ...
               strtrim( sprintf( '%s ', missingVars{:} ) ) );
    end
    varsToSave = userVarNames;
else
    varsToSave = allNames;
end

try
    % Build the DmatFile object for writing
    dmatFile = distributedutil.DmatFile.openForWrite( userFname );
catch E
    % Strip stack
    throw( E );
end

if tellUserFilename
    fprintf( 1, 'Saving to: %s\n', dmatFile.FileName );
end

for ii=1:length( varsToSave )
    try
        % By the time we get here, we should have checked transparency, so don't
        % expect that to fail.
        val = evalin( 'caller', varsToSave{ii} );
        iWriteOne( dmatFile, val, varsToSave{ii} );
    catch E
        warning( 'distcomp:dsave:ErrorDuringSave', ...
                 ['An error occurred saving "%s" and therefore this array ', ...
                  'has not been saved.\nThe error was:\n%s'], ...
                 varsToSave{ii}, getReport( E ) );
    end
end
dmatFile.commitWrites();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iWriteOne( dmatFile, val, varname )

if isa( val, 'distributed' )
    iWriteDistributed( dmatFile, val, varname );
elseif isa( val, 'Composite' )
    iWriteComposite( dmatFile, val, varname );
elseif isa( val, 'codistributed' )
    throwAsCaller( MException( 'distcomp:dsave:CantSaveCodistributed', ...
                               'DSAVE cannot save codistributed arrays, use PSAVE instead.' ) );
else
    iWriteData( dmatFile, val, varname );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is responsible for deciding on the chunking of the
% distributed data into the file. It uses hidden properties of the
% distributed array to find out how large the full array is, and also how to
% transfer the data.
function iWriteDistributed( dmatFile, D, varname )

% Cannot currently handle sparse distributed arrays.
if issparse( D )
    warning( 'distcomp:dsave:CantSaveSparse', ...
             ['DSAVE cannot currently save sparse distributed arrays, ', ...
              '''%s'' has not been saved.'], varname );
    return;
end

infoStruc = distributedutil.DsaveDloadParser.createManifestStruct( ...
    'distributed', D );
% Add the variable to the file
dmatFile.addVariable( varname, infoStruc );

% Create the region iterator to do the saving
regionIt = distributedutil.DistributedRegionIterator( D );

while regionIt.hasMoreRegions()
    region = regionIt.nextRegion();
    value  = hRetrieveData( D, region );
    dmatFile.writeVariableRegion( varname, value, region );
end
dmatFile.commitVariable( varname );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iWriteComposite( dmatFile, compObj, varname )
existFlag = exist( compObj ); %#ok<EXIST> Composite.exist
compLen   = length( compObj );

infoStruc = distributedutil.DsaveDloadParser.createManifestStruct( ...
    'Composite', compObj );
dmatFile.addVariable( varname, infoStruc );

for ii=1:compLen
    if existFlag(ii)
        labData = compObj(ii);
        region = struct( 'start', [1; ii], 'end', [1; ii] );
        dmatFile.writeVariableRegion( varname, labData, region );
    end
end
dmatFile.commitVariable( varname );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iWriteData( dmatFile, plainOldData, varname )
infoStruc = distributedutil.DsaveDloadParser.createManifestStruct( ...
    'data', plainOldData );
dmatFile.addCompleteVariable( varname, infoStruc, plainOldData );
dmatFile.commitVariable( varname );
end

