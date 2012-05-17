%DisplayHelperDense - knows how to display partial dense arrays.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/02/06 14:17:15 $
classdef DisplayHelperDense < distributedutil.DisplayHelper

    properties ( Access = private )
        % FullSizeVec - global size of distributed object
        FullSizeVec
        % A cell array length ndims of [e f] arrays.
        ShowingSizesCell

        % How many elements we actually have in each dimension of the value - simply
        % a cache of size of the value in the full dimensionality.
        NumGotInEachDim
    end
    
    %% Static helpers used in construction
    methods ( Static, Access = private )
        
        % assumption is that we're starting at element 1 in each dimension
        function c = deriveShowingSizesCellFromValue( value, globalNdims )
            % szGot := [2, 3, 4]
            szGot = size( value );
            % Ensure szGot is the right length (might be shorter than global size)
            szGot = [ szGot, ones( 1, globalNdims - length( szGot ) ) ];
            % oneToSzGot := [ 1, 2; 1, 3; 1, 4 ];
            oneToSzGot = [ ones( 1, length( szGot ) ); szGot ] .';
            % ShowingSizesCell is one cell per row of oneToSzGot
            c = mat2cell( oneToSzGot, ones( 1, length( szGot ) ), 2 );
        end

        function n = deriveNumGotInEachDim( showSzCell )
            n = zeros( 1, length( showSzCell ) );
            for ii=1:length( showSzCell )
                if isnumeric( showSzCell{ii} ) && length( showSzCell{ii} ) == 2
                    % Got an [e f] vector, work out how many elements that corresponds to.
                    ef = showSzCell{ii};
                    n(ii) = 1 + ( ef(2) - ef(1) );
                else
                    error( 'distcomp:distributedutil:InvalidInput', ...
                           'An unexpected error occurred during distributed display' );
                end
            end
        end
    end
    
    %% Public API
    methods
        
        % Construct with: 
        % name: name of the variable;
        % classname: the "distributed" or whatever class;
        % value: the (truncated) value to be displayed; 
        % fullsz: the full size of the underlying object;
        % showingsz: (optional arg) and a cell array describing the size of the
        % value. This cell array should be the same length as the full size,
        % and contain entries which are either ':' (implying no truncation),
        % or [e f] (which are the first and last indices in that dimension).
        %
        % 'showingsz' may be omitted if the value is a simple truncation of
        % the full array (i.e. from 1:size(value,dim) in each dimension)
        function obj = DisplayHelperDense( name, classname, value, fullsz, showingsz )
            % Set up base class properties.
            obj.Name             = name;
            obj.ClassName        = classname;
            obj.Value            = value;
            
            obj.FullSizeVec      = fullsz;
            
            if nargin < 5
                obj.ShowingSizesCell = distributedutil.DisplayHelperDense.deriveShowingSizesCellFromValue( ...
                    value, length( obj.FullSizeVec ) );
            else
                obj.ShowingSizesCell = showingsz;

                % Check that showingsz is the same length as FullSizeVec
                if length( obj.ShowingSizesCell ) ~= length( obj.FullSizeVec )
                    error( 'distcomp:distributedutil:InvalidArgument', ...
                           ['An unexpected error occurred during distributed display: mismatch between ', ...
                            'local size and global size'] );
                end

                % Resolve ':' in ShowingSizesCell
                for ii = 1:length( obj.ShowingSizesCell )
                    if ischar( obj.ShowingSizesCell{ii} ) && strcmp( obj.ShowingSizesCell{ii}, ':' )
                        obj.ShowingSizesCell{ii} = [1 obj.FullSizeVec(ii)];
                    else
                        % Error check here - this is the only place where we've got user-supplied
                        % ShowingSizesCell to verify.
                        ef = obj.ShowingSizesCell{ii};
                        nThisDim = 1 + ( ef(2) - ef(1) );
                        if nThisDim == size( obj.Value, ii ) && nThisDim <= obj.FullSizeVec(ii)
                            % ok
                        else
                            error( 'distcomp:distributedutil:InvalidArgument', ...
                                   ['An unexpected error occurred during distributed display: mismatch between ', ...
                                    'local size and global size'] );
                        end
                    end
                end
            end
            
            % Derive the NumGotInEachDim
            obj.NumGotInEachDim = distributedutil.DisplayHelperDense.deriveNumGotInEachDim( ...
                obj.ShowingSizesCell );
            
            % Finally, derive the IsTruncated flag.
            obj.IsTruncated = any( obj.NumGotInEachDim < obj.FullSizeVec );
        end
        
        function doDisp( obj )
        %DODISP - public method to implement "disp"
            if ~any( obj.FullSizeVec == 0 )
                obj.denseDisplay( 'disp' );
            end
        end
        
        function doDisplay( obj )
        %DODISPLAY - public method to implement "display"
            if any( obj.FullSizeVec == 0 )
                obj.emptyDisplay();
            else
                obj.denseDisplay( 'display' );
            end
        end
    end

    %% Protected methods needed by superclass implementation
    methods ( Access = protected )
        function res = formatEndTruncationMsg( obj )
        % formatEndTruncationMsg - build up the message to show after the completion
        % of disp(lay).
            if obj.IsTruncated
                % Format the string describing what we're actually showing
                showingDescCell = repmat( {':'}, 1, length( obj.FullSizeVec ) );
                for ii=1:length( obj.FullSizeVec )
                    if obj.NumGotInEachDim(ii) ~= obj.FullSizeVec(ii)
                        % XXX:SIMPLIFICATION - assuming elements of ShowingSizesCell are length 2
                        showing = obj.ShowingSizesCell{ii};
                        showingDescCell{ii} = sprintf( '%d:%d', showing(1), showing(2) );
                    end
                end
                % showingStr := '1:2, 1:3, 1:4, '
                showingStr = sprintf( '%s, ', showingDescCell{:} );
                showingStr = showingStr( 1:end-2 );
                
                % Format the 3-by-7-by-47474 string for the whole array
                fullSizeStr = sprintf( '%d-by-', obj.FullSizeVec );
                % trim the final -by- from sprintf
                fullSizeStr = fullSizeStr(1:end-4);
                
                % Format the whole truncation message
                res = sprintf( '<... display truncated: showed [%s] of %s>', ...
                               showingStr, fullSizeStr );
            else
                res = '';
            end
        end
    end
    
    %% Private implementation methods
    methods ( Access = private )
        function denseDisplay( obj, type )
        % Display what we've got by pages. If there are 3 or more dimensions in the
        % full array, we'll do the "d(...) = " line; otherwise, we'll do the
        % "d = " line. 
            
            fullValueIsMultipage = ( length( obj.FullSizeVec ) >= 3 );
            
            if fullValueIsMultipage
                truncatedValuePagesGot = prod( obj.NumGotInEachDim(3:end) );
                showPageRange = true;
                for localPageIdx = 1:truncatedValuePagesGot
                    page = obj.Value( :, :, localPageIdx );
                    obj.displayOnePage( type, showPageRange, localPageIdx, page );
                end
            else
                showPageRange = false;
                obj.displayOnePage( type, showPageRange, 1, obj.Value );
            end
            obj.showEndTruncationMessage();
        end
        
        function displayOnePage( obj, type, showPageRange, localPageIdx, pageValue )
        % displayOnePage - print the name line (if req'd), and the value
            if showPageRange
                obj.nameLine( type, obj.formatPageRange( localPageIdx ), obj.formatPageTruncationMsg() );
            else
                noPageRange = '';
                obj.nameLine( type, noPageRange, obj.formatPageTruncationMsg() );
            end
            disp( pageValue );
        end
        
        function globalPageRange = formatPageRange( obj, localPageIdx )
        % Given: a page index into the local value, figure out the global page

        % For example: if the global size is [3, 4, 5, 6]; and the ShowingSizesCell
        % is something like: { [2, 3], [2, 4], [2, 4], [1, 2] }, then the
        % local value has 6 pages, the first of which corresponds to the
        % global page (2:3,2:4,2,1). 

        % SO: What we need to do is work out the local subscripts of the top-left
        % of this local page, and then offset that back up to the global indices
            
        % XXX:SIMPLIFICATION: consider only 2-element ShowingSizesCell
        % entries.
            localIndexOfPageStart = 1 + ( ( localPageIdx - 1 ) * prod( obj.NumGotInEachDim(1:2) ) );
            
            localSubscriptsOfPageStart = cell( 1, length( obj.NumGotInEachDim ) );
            [localSubscriptsOfPageStart{:}] = ind2sub( obj.NumGotInEachDim, localIndexOfPageStart );
            % Convert from cell array to column vector of local subscripts
            localSubscriptsOfPageStart = vertcat( localSubscriptsOfPageStart{:} );
            
            % Now that we know the subscripts of the start of the page we're showing in
            % local co-ordinates, we need to offset that to work out the
            % subscripts in the global array.
            
            % Concatenate all the [e f] tiny vectors to an overall offset matrix - the
            % offset we want is all the "e"s as a column vector.
            showingSzsAsMatrix = vertcat( obj.ShowingSizesCell{:} );
            
            % We need to add (e-1) to each local subscript to get the global subscript
            offsetsLocalToGlobal = showingSzsAsMatrix(:,1) - 1;
            
            % Now we can calculate the global subscripts of the top-left of the page
            globalSubscriptsOfPageStart = localSubscriptsOfPageStart + offsetsLocalToGlobal;
            
            % Finally, build the resulting string. NB: here, I'm hard-wiring the first
            % two dimensions to be ':'
            pageRange3ToEnd = sprintf( '%d,', globalSubscriptsOfPageStart(3:end) );
            pageRange3ToEnd = pageRange3ToEnd( 1:end-1 ); % remove trailing comma
            globalPageRange = sprintf( '(:,:,%s)', pageRange3ToEnd );
        end
        
        function res = formatPageTruncationMsg( obj )
            if any( obj.FullSizeVec(1:2) > obj.NumGotInEachDim(1:2) )
                % XXX:SIMPLIFICATION - assuming elements of ShowingSizesCell are length 2
                ssc1 = obj.ShowingSizesCell{1};
                ssc2 = obj.ShowingSizesCell{2};
                res = sprintf( ' <page truncated: showing [%d:%d, %d:%d] of %d-by-%d>', ...
                               ssc1(1), ssc1(2), ssc2(1), ssc2(2), ...
                               obj.FullSizeVec(1), obj.FullSizeVec(2) );
            else
                % Not truncated
                res = '';
            end
        end

        function emptyDisplay( obj )
        % Must be doing "display", so always show the name.
            noTruncMessage = '';
            noRangeStr     = '';
            obj.nameLine( 'display', noRangeStr, noTruncMessage );
            
            % Compute "emptyMsg"
            if length( obj.FullSizeVec ) == 2 && all( obj.FullSizeVec == 0 )
                % Special case: 0-by-0 is displayed as: []
                emptyMsg = '     []';
            else
                % Describe the array
                if length( obj.FullSizeVec ) == 2
                    matrixOrArray = 'matrix';
                else
                    matrixOrArray = 'array';
                end
                emptyArrayDesc = sprintf( 'Empty %s %s', obj.ClassName, matrixOrArray );

                % Build the 3-by-0 type string
                sizeStr = sprintf( '%d-by-', obj.FullSizeVec );
                % Trim the final trailing "-by-"
                sizeStr = sizeStr( 1:end-4 );
                
                emptyMsg = sprintf( '   %s: %s', emptyArrayDesc, sizeStr );
            end
            fprintf( 1, '%s\n%s', emptyMsg, obj.separator() );
        end
    end
end
