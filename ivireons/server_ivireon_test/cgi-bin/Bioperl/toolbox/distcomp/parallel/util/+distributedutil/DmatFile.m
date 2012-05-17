%DmatFile is an undocument OO interface used by DSAVE and DLOAD

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/11/07 20:52:15 $
classdef ( Sealed = true, Hidden ) DmatFile < handle

    properties ( Constant = true )
        % The definition of our default file extension.
        FileExt = '.mat';
        
        % The name of the MANIFEST information in the MAT file
        ManifestName = 'DMAT_MANIFEST';
        
        % The version numbers to place in the manifest to check for compatibility.
        MajorVersion = 1;
        MinorVersion = 1;
    end
    
    properties ( Access = public )
        % The underlying filename, used by dload and dsave
        FileName
    end
    
    properties ( Access = private )
        %% The following 4 lists are all related properties, and are saved in the
        % MANIFEST of the dmat file:
        % List of var names in the file
        VariableNames

        % List of full sizes
        FullSizes
        
        % Info Structures giving extra information about e.g. distributed
        % data types.
        InfoStructs
        
        % Has this variable been fully written - when writing, the writer must
        % commit each variable in turn.
        CompleteFlag

        %%
        % In Save mode - we need to "commit" the writes by appending the manifest
        % information. In load mode, we do not.
        NeedToCommitWrites = false
        
        % a distributedutil.DmatFileMode
        Mode
    end
    
    methods ( Static )
        function obj = openForRead( fileName )
        % We attempt to open the file in "read" mode, but we may end up in
        % "readcompat" mode.
            obj = distributedutil.DmatFile( fileName, distributedutil.DmatFileMode.PartialReadMode );
        end
        function obj = openForWrite( fileName )
            obj = distributedutil.DmatFile( fileName, distributedutil.DmatFileMode.WriteMode );
        end
    end
    
    methods ( Static, Hidden )
        function saveCreateArgs = sSaveCreateArgs( optNewVal )
            persistent current
            if isempty( current )
                % If not in v7.3 mode, partial writing will fail.
                current = { '-v7.3' };
            end
            saveCreateArgs = current;
            if nargin == 1
                if iscell( optNewVal )
                    current = optNewVal;
                else
                    error( 'distcomp:DmatFile:SaveCreateCell', ...
                           'The argument to sSaveCreateArgs must be a cell array' );
                end
            end
        end
    end
    
    methods ( Access = private )
        function pAssertInWriteMode( obj )
        % Assert that we're in write mode, and that we haven't finished writing.
            if ~obj.Mode.canWrite()
                error( 'distcomp:dsaveload:BadMode', ...
                       'Invalid mode for operation - write mode required' );
            end
            if ~obj.NeedToCommitWrites
                error( 'distcomp:dsaveload:WritesCommitted', ...
                       'Invalid mode for operation - writes already committed for file: %s', ...
                       obj.FileName );
            end
        end
        
        function pAssertInReadMode( obj )
        % Assert that we're in read mode
            if ~obj.Mode.canRead()
                error( 'distcomp:dsaveload:BadMode', ...
                       'Invalid mode for operation - read mode required.' );
            end
        end
        
        function idx = pGetVarIndexOrError( obj, varName )
        % Find the index into the lists of the given variable name, or error.
            idx = strmatch( varName, obj.VariableNames, 'exact' );
            if length( idx ) ~= 1
                throwAsCaller( MException( 'distcomp:DmatFile:InvalidVariable', ...
                                           'The variable %s was not found in %s.', ...
                                           varName, obj.FileName ) );
            end
        end

        function v = pGetFullVarFromMatFile( obj, varname )
        % Read a complete variable from the file.
            v = load( obj.FileName, varname );
            v = v.(varname);
        end
        
        function v = pGetVarFromMatFile( obj, varname, varFullSize, regionStruct )
        % Return the value stored in the file.
        % Use partial load only if necessary
            if all( regionStruct.start == 1 ) && ...
                    all( regionStruct.end == varFullSize(:) )
                % Full load
                v = obj.pGetFullVarFromMatFile( varname );
            else
                % Require partial load
                
                if obj.Mode ~= distributedutil.DmatFileMode.PartialReadMode
                    error( 'distcomp:DmatFile:InvalidMatFile', ...
                           'An unexpected attempt was made to read a portion of "%s" from file "%s"', ...
                           varname, obj.FileName );
                end
                
                v = obj.pPartialLoad( varname, [regionStruct.start, regionStruct.end] );
            end
        end

        function tmpl = pReadTemplate( obj, varname, fullSize )
        % Should have already asserted read mode, no need to do that again.
            startsEnds = ones( length( fullSize ), 2 );
            tmpl       = obj.pPartialLoad( varname, startsEnds );
        end
        
        function resolvedName = pCreateDMatFile( ~, fileName )
        % Create an empty DMAT-format file.
            try
                s = struct(); %#ok<NASGU> empty structure - create an empty MAT file
                saveCreateArgs = distributedutil.DmatFile.sSaveCreateArgs();
                save( fileName, saveCreateArgs{:}, '-struct', 's' );
                resolvedName = ...
                    distributedutil.DmatFile.sResolveFileNameForExistingFile( fileName );
            catch E
                EE = MException( 'distcomp:DmatFile:CouldNotSave', ...
                                 'Could not save to file: %s', fileName );
                EE = addCause( EE, E );
                throw( EE );
            end
        end
        
        function varSubs = pStartEndToVarSubsets( ~, varname, startsEnds )
        % Convert an ndims-by-2 array of starts and ends into a VariableSubset
        % object.
            nd      = size( startsEnds, 1 );
            % We need to convert the starts/ends array (first column is starts, second
            % column is ends) into the form that Subset requires, which is a
            % cell array of nd elements, each of which is a start-end pair.
            
            % Use mat2cell to convert the array into cells. We want to make a cell from
            % each of the "nd" rows, so the vector of row sizes is just
            % ones(nd,1) and the we always take all columns
            c       = mat2cell( startsEnds, ones( nd, 1 ), 2 );
            
            % That cell array is the wrong way around - Subset needs a row-oriented cell
            % array.
            c       = transpose( c );
            
            % Build the Subset and VariableSubset.
            subsets = internal.matlab.language.Subset( '()', c );
            varSubs = internal.matlab.language.VariableSubset( varname, subsets );
        end
        
        function tf = pStartEndIsEmpty( ~, startsEnds )
        % Takes an ndims-by-2 "starts ends" array
            tf = any( startsEnds(:,2) < startsEnds(:,1) ) || ...
                 any( startsEnds(:,2) == 0 );
        end
        
        function v = pPartialLoad( obj, varName, startsEnds )
        % Wrapper around _load, handles loading of empties (not handled by Subset)
            if obj.pStartEndIsEmpty( startsEnds )
                % empty
                s = load( obj.FileName, varName );
                v = s.(varName);
            else
                varSubs = obj.pStartEndToVarSubsets( varName, startsEnds );
                v = internal.matlab.language.partialLoad( obj.FileName, varSubs, '-mat' );
            end
        end
        
        function pPartialSave( obj, varName, value, startsEnds )
        % Defend against empty values, not handled by Subset objects
            if obj.pStartEndIsEmpty( startsEnds )
                % empty
                obj.pPutFullVarInMatFile( varName, value );
            else
                varSubs = obj.pStartEndToVarSubsets( varName, startsEnds );
                internal.matlab.language.partialSave( obj.FileName, value, varSubs );
            end
        end
        
        function pPutVarInMatFile( obj, varname, regionStruct, value )
        % Put a partial variable into a pre-existing MAT file
            if exist( obj.FileName, 'file' )
                obj.pPartialSave( varname, value, [regionStruct.start, regionStruct.end] );
            else
                error( 'distcomp:DmatFile:FileNotFound', ...
                       'Unexpected failure to save data to file: %s', obj.FileName );
            end
        end
        
        function pPutFullVarInMatFile( obj, varName, value )
        % Put a complete variable into the MAT file
            s.(varName) = value; %#ok<STRNU>
            save( obj.FileName, '-append', '-struct', 's' );
        end
        
        function pCreateVarInFile( obj, varname, template, fullSize )
        % Create a new variable in the file, pre-allocating it to the full size.
            if exist( obj.FileName, 'file' )
                startsEnds = [fullSize(:), fullSize(:)];
                obj.pPartialSave( varname, template, startsEnds );
            else
                error( 'distcomp:DmatFile:FileNotFound', ...
                       'Unexpected failure to save data to file: %s', obj.FileName );
            end
        end
        
        function pWarnIfAnyVarsNotComplete( obj )
        % When committing writes, warn about those variables that haven't been
        % written correctly.
            if ~all( obj.CompleteFlag )
                incompleteVarNamesStr = strtrim( ...
                    sprintf( '''%s'' ', obj.VariableNames{ ~obj.CompleteFlag } ) );
                warning( 'distcomp:DmatFile:IncompleteVariables', ...
                         'The following variable(s) were not completely written to %s:\n%s', ...
                         obj.FileName, incompleteVarNamesStr );
            end
        end
        
        function gotManifest = pReadManifestInformation( obj )
        % Read MANIFEST information if available. Return success flag.
        % try catch around this next line to defend against unreadable / corrupt MAT files.
            try 
                info = whos( '-file', obj.FileName, ...
                             distributedutil.DmatFile.ManifestName );
            catch E
                EE = MException( 'distcomp:DmatFile:FailedToReadFile', ...
                                 'Could not read from file: %s', obj.FileName );
                EE = addCause( EE, E );
                throwAsCaller( EE );
            end

            gotManifest = ~isempty( info );
            if gotManifest
                
                tmpStruct = load( obj.FileName, ...
                                 distributedutil.DmatFile.ManifestName );
                manifest  = ...
                    tmpStruct.(distributedutil.DmatFile.ManifestName);

                thisVersionStr = sprintf( '%d:%d', distributedutil.DmatFile.MajorVersion, ...
                                          distributedutil.DmatFile.MinorVersion );
                fileVersionStr = sprintf( '%d:%d', manifest.MajorVersion, ...
                                          manifest.MinorVersion );
                
                % Check the version
                % Error if file.major > this.major; warn if file.minor > this.minor
                if manifest.MajorVersion > distributedutil.DmatFile.MajorVersion
                    error( 'distcomp:DmatFile:NewerVersion', ...
                           ['The version of file "%s" is: %s, which is not compatible ', ...
                            'with the current supported version, %s.'], ...
                           obj.FileName, fileVersionStr, thisVersionStr );
                elseif manifest.MinorVersion > distributedutil.DmatFile.MinorVersion
                    warning( 'distcomp:DmatFile:NewerVersion', ...
                             ['The version of file "%s" is: %s, which is newer ', ...
                              'than the current supported version, %s. Some information ', ...
                              'may be lost when loading data.' ], ...
                             obj.FileName, fileVersionStr, thisVersionStr );
                end
                
                obj.VariableNames   = manifest.VariableNames;
                obj.FullSizes       = manifest.FullSizes;
                obj.CompleteFlag    = manifest.CompleteFlag;
                obj.InfoStructs     = manifest.InfoStructs;
            end
        end
        
        function pConcoctManifestInformation( obj )
        % We're in compatibility mode, concoct what information we can.
            allVarInfo          = whos( '-file', obj.FileName );
            obj.VariableNames   = {allVarInfo.name};
            obj.FullSizes       = {allVarInfo.size};
            obj.CompleteFlag    = true( length( obj.VariableNames ), 1 );
            obj.InfoStructs     = cell( 1, length( obj.VariableNames ) );
            for ii=1:length( obj.VariableNames )
                obj.InfoStructs{ii} = ...
                    distributedutil.DsaveDloadParser.concoctManifestStruct( ...
                        obj.FullSizes{ii}, allVarInfo(ii).class, allVarInfo(ii).sparse );
            end
        end
        
        function pAddVarShared( obj, varName, infoStruc )
            % Shared, private method for adding a variable to a file. Three slightly
            % different modes of operation for Composites, distributeds,
            % and data. 
            obj.pAssertInWriteMode();
            if ismember( varName, obj.VariableNames )
                error( 'distcomp:DmatFile:InvalidState', ...
                       'The variable named %s already exists in file %s', ...
                       varName, obj.FileName );
            end

            idxInManifest = 1 + length( obj.VariableNames );
            obj.VariableNames{idxInManifest} = varName;
            obj.FullSizes{idxInManifest}     = infoStruc.Size;
            obj.CompleteFlag(idxInManifest)  = false;
            obj.InfoStructs{idxInManifest}   = infoStruc;
            
            % Switchyard for different types
            switch infoStruc.Type
              case 'distributed'
                template = infoStruc.Info.Template;
                obj.pCreateVarInFile( varName, template, infoStruc.Size );
              case 'Composite'
                template = {[]};
                obj.pCreateVarInFile( varName, template, infoStruc.Size );
              case 'data'
                % Nothing to do - the appropriate add var method will
                % simply place the entire variable in the file.
              otherwise
                error( 'distcomp:DmatFile:InvalidType', ...
                       'An unexpected error was encountered saving "%s"', varName );
            end
            
        end
        
    end
    
    methods ( Access = private, Static )
        function fnameWithExt = sAppendExtIfNecessary( fileName )
        % Put ".dmat" at the end of any names which don't already have an extension.
            [~,~,ext] = fileparts( fileName );
            if isempty( ext )
                % Append the file extension.
                fnameWithExt = [fileName, distributedutil.DmatFile.FileExt];
            else
                fnameWithExt = fileName;
            end
        end
        
        function resolvedFname = sResolveFileNameForExistingFile( userFname ) 
        % treat "userfName" as final
        % use "fopen" to attempt tor read from the file. If we successfully open it
        % for reading, FOPEN can give us the resolved filename. Otherwise we
        % can error.
            
        % TMP use internal.matlab.language.findFullMATFilename when available
            [fh, message] = fopen( userFname, 'rb' );
            if fh ~= -1
                resolvedFname = fopen( fh );
                fclose( fh );
            else
                error( 'distcomp:DmatFile:FileNotFound', ...
                       'Unable to find file %s: %s', userFname, message );
            end
        end
    end
    
    methods ( Access = private )
        function obj = DmatFile( fileName, mode )
        % Private constructor - public access via static methods.
            obj.Mode = mode;
            
            fnameWithExt = distributedutil.DmatFile.sAppendExtIfNecessary( fileName );
            
            if isequal( mode, distributedutil.DmatFileMode.PartialReadMode )
                % On read, attempt to resolve the filename (because "whos" doesn't
                % understand all the same syntaxes as "load")
                obj.FileName = distributedutil.DmatFile.sResolveFileNameForExistingFile( fnameWithExt );
                
                % We can deduce the information that we need from the
                % contents of the file.
                didReadManifest = obj.pReadManifestInformation();
                if ~didReadManifest
                    obj.pConcoctManifestInformation();
                end

                if internal.matlab.language.isPartialMATArrayAccessEfficient( obj.FileName )
                    obj.Mode = distributedutil.DmatFileMode.PartialReadMode;
                else
                    % Must load whole variables
                    if didReadManifest
                        % How did we get here?
                        warning( 'distcomp:DmatFile:UnexpectedFileType', ...
                                 ['The file "%s" appears to have been saved using DSAVE, ', ...
                                  'but the file does not support loading partial arrays. ', ...
                                  'This may cause excessive memory usage.'], obj.FileName );
                    end
                    % ReadCompatMode implies no partial loading
                    obj.Mode = distributedutil.DmatFileMode.ReadCompatMode;
                end
                    
            elseif isequal( mode, distributedutil.DmatFileMode.WriteMode )

                % Ensure we can write to the file before we go any further and resolve the
                % file name. This might throw an error.
                obj.FileName = obj.pCreateDMatFile( fnameWithExt );
                                
                % Empty information
                obj.VariableNames      = cell(0,1);
                obj.FullSizes          = cell(0,1);
                obj.CompleteFlag       = false(0,1);
                obj.InfoStructs        = cell(0,1);
                obj.NeedToCommitWrites = true;
            else
                % Never get here - private constructor.
                error( 'distcomp:DmatFile:InvalidMode', ...
                       'Invalid DmatFile mode specified.' );
            end
        end
    end % private constructor block
    
    methods ( Access = public )
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This block is all the methods relating to saving variables in a
        % DmatFile. To save a single variable, you must first call:
        %
        %    dmatFile.addVariable( 'varName', infoStruc )
        %
        % and then any number of calls to:
        % 
        %    dmatFile.writeVariableRegion( 'varName', value, regionStruct )
        %
        % to add individual chunks to that variable. Once you're done with a
        % given variable, you need to commit it to indicate that no more
        % regions are needed:
        %
        %    dmatFile.commitVariable( 'varName' );
        %
        % You can also add complete variables as a one-off call to:
        %
        %    dmatFile.addCompleteVariable( 'varName', infoStruc, value );
        %
        % Once you're done adding all variables, finalise the file by
        % calling:
        %
        %    dmatFile.commitWrites();
        %
        % After that, you can no longer add variables or regions.
        
        function addVariable( obj, varName, infoStruc )
        % Add a new variable to the file prior to adding data
        % Args:
        % - varName - the name of the variable
        % - infoStruc - the info structure
            obj.pAddVarShared( varName, infoStruc );
        end
        
        function addCompleteVariable( obj, varName, infoStruc, value )
        % Add a new complete variable with no option to perform a partial
        % write
            obj.pAddVarShared( varName, infoStruc );
            obj.pPutFullVarInMatFile( varName, value );
        end
        
        function writeVariableRegion( obj, varName, value, regionStruct )
        % Add a portion of a variable that has already been added using addVariable.
        % Args:
        % - varName - the name of the variable as passed to addVariable
        % - value - a portion of the value
        % - regionStruct - describe the extent of "value" within the global array.
            
            obj.pAssertInWriteMode();
            
            % Actually save the data
            obj.pPutVarInMatFile( varName, ...
                                  regionStruct, value );
        end
        
        function commitVariable( obj, varName )
        % Indicate all regions are complete for varName. After this call, no more
        % regions may be added.
            obj.pAssertInWriteMode();
            idx = obj.pGetVarIndexOrError( varName );
            if obj.CompleteFlag( idx )
                error( 'distcomp:DmatFile:InvalidCommit', ...
                       'The variable "%s" has already been committed', varName );
            else
                obj.CompleteFlag( idx ) = true;
            end
        end
        
        function obj = commitWrites( obj )
        % Finalise all data into the file. No more variables may be added after this
        % call.
            
            obj.pAssertInWriteMode();
            
            % Issue a warning if any variables weren't completely written
            obj.pWarnIfAnyVarsNotComplete();
            
            % Write the MANIFEST information out to the file - build the manifest. Avoid
            % the "struct" constructor since the fields are all cells, and I
            % want to keep it that way.
             manifest.VariableNames = obj.VariableNames;
             manifest.InfoStructs   = obj.InfoStructs;
             manifest.FullSizes     = obj.FullSizes;
             manifest.CompleteFlag  = obj.CompleteFlag;
             manifest.MajorVersion  = distributedutil.DmatFile.MajorVersion;
             manifest.MinorVersion  = distributedutil.DmatFile.MinorVersion;
             obj.pPutFullVarInMatFile( distributedutil.DmatFile.ManifestName, ...
                                       manifest );
            % Ensure that we don't come through here again
            obj.NeedToCommitWrites = false;
        end
        
        function delete( obj )
        % delete function here ensures that if the user CTRL-Cs out of DSAVE, then
        % what data has been written can be committed safely.
            if obj.NeedToCommitWrites
                warning( 'distcomp:DmatFile:SaveAborted', ...
                         'A call to DSAVE did not complete normally; data may be corrupt in %s', ...
                         obj.FileName );
                % Indicate that we didn't complete normally.
                obj.commitWrites();
            end
        end

    end % End of "Write" public API
    
    methods ( Access = public ) % "Read" public API

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This block is all the methods relating to reading variables from a
        % DmatFile. The recommended sequence is: firstly, get a list of
        % available variables (only those which were completely written will
        % be returned):
        %
        %    varsInFile = dmatFile.getVariableNames();
        %
        % For a particular variable, get the information needed to
        % reconstitute it:
        % 
        %    [infoStruc, supportsPartial] = dmatFile.getVariableMetadata( 'varName' );
        %
        % if "supportsPartial" is true, then partial regions may be read using:
        %
        %    data = dmatFile.readVariableRegion( 'varName', regionStruc )
        %
        % This gives you the data to apply to your global array.
        
        function varNames = getVariableNames( obj )
        % Return only those variable names for which we have complete data as a cell
        % array.
            obj.pAssertInReadMode();
            varNames = obj.VariableNames( obj.CompleteFlag );
        end
        
        function [infoStruct, supportsPartialRead] = getVariableMetadata( obj, varName )
        % Return the three pieces of metadata about a variable - the first two were
        % defined in "addVariable"; the third is the number of times that
        % "readVariableRegion" can be called.
            obj.pAssertInReadMode();
            idx        = obj.pGetVarIndexOrError( varName );
            infoStruct = obj.InfoStructs{ idx };
            
            % Need to override supportsPartialRead if it's Type==data and sparse.
            if isequal( infoStruct.Type, 'data' ) && infoStruct.Info.Sparse
                supportsPartialRead = false;
            else
                supportsPartialRead = ( obj.Mode == ... 
                                        distributedutil.DmatFileMode.PartialReadMode );
            end
        end
        
        function data = readCompleteVariable( obj, varName )
        % Read a whole variable in one go.
            obj.pAssertInReadMode();
            % Don't store the index, just check the data exists.
            obj.pGetVarIndexOrError( varName );
            data = obj.pGetFullVarFromMatFile( varName );
            if isa( data, 'distributed' ) || isa( data, 'Composite' )
                % Error because we found distributed/Composite data in a standard MAT-File.
                error( 'distcomp:DmatFile:LoadedRemoteDataFromMatFile', ...
                       ['Data of class: %s was loaded from %s. This data is ', ...
                        'invalid. Use DSAVE to save this type of data'], ...
                       class( data ), obj.FileName );
            end
        end
        
        function data = readVariableRegion( obj, varName, regionStruct )
        % Return the data and regionstruct for the given region of the given
        % variable.
            obj.pAssertInReadMode();

            idx = obj.pGetVarIndexOrError( varName );

            % Read the region
            data = obj.pGetVarFromMatFile( varName, obj.FullSizes{idx}, regionStruct );
        end
    end
end
