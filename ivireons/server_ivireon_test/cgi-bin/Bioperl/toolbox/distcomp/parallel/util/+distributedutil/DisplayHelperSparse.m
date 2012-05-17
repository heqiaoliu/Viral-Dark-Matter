%DisplayHelperSparse - knows how to display partial sparse arrays.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/02/06 14:17:17 $
classdef DisplayHelperSparse < distributedutil.DisplayHelper

    properties ( Access = private )
        % Store both nnz of the full distributed sparse, and the number of non-zeros
        % we're going to display.
        FullNNZ
        ShowingNZ
    end
    
    methods
        function obj = DisplayHelperSparse( name, classname, value, fullNNZ )
        % Sparse display works by trimming non-zeros, not changing the size of
        % distributed array. Perhaps this might need to change for
        % codistributed?
            obj.Name        = name;
            obj.ClassName   = classname;
            obj.Value       = value;
            obj.FullNNZ     = fullNNZ;
            obj.ShowingNZ   = nnz( obj.Value );
            obj.IsTruncated = ( obj.ShowingNZ < fullNNZ );
        end
    end
    
    methods ( Access = protected )
        function res = formatEndTruncationMsg( obj )
            if obj.IsTruncated
                res = sprintf( '<... display truncated: showed %d of %d non-zeros>', ...
                               obj.ShowingNZ, obj.FullNNZ );
            else
                res = '';
            end
        end
    end
    
    methods
        function doDisp( obj )
            if ~isempty( obj.Value )
                obj.sparseDisplay( 'disp' );
            end
        end
        function doDisplay( obj )
            if isempty( obj.Value )
                obj.emptyDisplay();
            else
                obj.sparseDisplay( 'display' );
            end
        end
    end
    
    methods ( Access = private )
        function emptyDisplay( obj )
            noPage         = '';
            noTruncMsg     = '';
            typeIsDisplay  = 'display';
            sz             = size( obj.Value );
            emptyArrayDesc = sprintf( 'All zero %s sparse', obj.ClassName );

            obj.nameLine( typeIsDisplay, noPage, noTruncMsg );
            fprintf( 1, '   %s: %d-by-%d\n%s', emptyArrayDesc, ...
                     sz(1), sz(2), obj.separator() );
        end
        function sparseDisplay( obj, type )
        % sparseDisplay - handle overall disp(lay) of sparse
            if strcmp( type, 'display' )
                noPage     = '';
                noTruncMsg = '';
                obj.nameLine( type, noPage, noTruncMsg );
            end
            disp( obj.Value );
            obj.showEndTruncationMessage();
        end
    end
end
