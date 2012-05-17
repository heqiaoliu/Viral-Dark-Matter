%DsaveDloadParser - helper class for DSAVE and DLOAD

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/11/07 20:52:16 $
classdef ( Sealed = true, Hidden ) DsaveDloadParser

    properties ( Constant, Hidden )
        % 128 MB.
        DefaultBlockSizeBytes = 128 * 2^20;
    end
    
    methods ( Static, Hidden )
        
        function struc = concoctManifestStruct( fullSz, clzz, spFlag )
        % Fabricate an info structure appropriate to raw data from the given full
        % size.
            struc = struct( 'Type', 'data', ...
                            'Size', fullSz, ...
                            'Info', struct( 'Class', clzz, 'Sparse', spFlag ) );
        end
        
        function struc = createManifestStruct( type, var )
        % Construct the structure to be stored in the MAT file manifest
            switch type
              case 'distributed'
                % _save cannot handle adding the complex part, so we must ensure here that
                % complex data is correctly handled.
                tmpl = distributedutil.Allocator.extractTemplate( var );
                % In the future, add distribution scheme details here.
                info = struct( 'Template', tmpl );
              case 'Composite'
                info = struct( 'Exist', exist( var ) ); %#ok<EXIST> this is Composite.exist()
              case 'data'
                info = struct( 'Class', class( var ), 'Sparse', issparse( var ) );
              otherwise
                error( 'distcomp:dsaveload:InvalidTypeInformation', ...
                       'Invalid type information was provided: %s', type );
            end
            struc = struct( 'Type', type, ...
                            'Size', size( var ), ...
                            'Info', info );
        end
        
        function szBytes = blockSizeBytes( optArg )
        % Undocumented access to the desired block size used by dsave.  Return the
        % old value, set the new value. DSAVE looks at this value to see how
        % to slice a distributed array.
            persistent blockSize
            if isempty( blockSize )
                blockSize = distributedutil.DsaveDloadParser.DefaultBlockSizeBytes;
            end
            szBytes = blockSize;
            if nargin == 1
                blockSize = optArg;
            end
        end
        
        % Parse the options given to DSAVE or DLOAD. Pick out the specified file
        % name (might be empty); decide whether to tell the user the
        % filename of what we're saving or loading; pick out the legal
        % arguments or error; pick out the list of variables requested
        % (again, might be empty).
        function [fileName, informUserFileName, optionArgs, varNames] = parseOptions( fcn, argList, allowedOptions )
        % Check that we've got only strings
            if ~all( cellfun( @ischar, argList ) )
                error( sprintf( 'distcomp:%s:StringArgs', fcn ), ...
                       'All arguments to %s must be strings', upper( fcn ) );
            end
            
            % Strip off options first - anything beginning with "-"
            optionStartIdx = regexp( argList, '^-' );
            isNotOption    = cellfun( @isempty, optionStartIdx );
            optionArgs     = argList( ~isNotOption );
            remainingArgs  = argList( isNotOption );
            
            % Check options against allowedOptions
            illegalOptions = setdiff( optionArgs, allowedOptions );
            if ~isempty( illegalOptions )
                illegalOptionsStr = strtrim( sprintf( '%s ', illegalOptions{:} ) );
                error( sprintf( 'distcomp:%s:IllegalArgument', fcn ), ...
                       'The following illegal argument(s) were passed to %s: %s', ...
                       upper( fcn ), illegalOptionsStr );
            end
            
            % Extract the filename if specified
            if length( remainingArgs ) >= 1
                
                fileName = remainingArgs{1};
                
                % Strip from arg list.
                remainingArgs(1) = [];
                
                % Don't need to tell the user - they knew what they were doing
                informUserFileName = false;
            else
                fileName = ['matlab' distributedutil.DmatFile.FileExt];
                % Inform user
                informUserFileName = true;
            end
            
            % All the rest are variable names
            varNames = remainingArgs;
        end
    end
end
