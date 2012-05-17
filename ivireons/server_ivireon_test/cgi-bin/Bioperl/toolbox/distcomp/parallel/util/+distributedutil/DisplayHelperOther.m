% DisplayHelperOther - helper class used for display non-numeric distributed
% objects.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/02/06 14:17:16 $
classdef DisplayHelperOther < distributedutil.DisplayHelper

    properties ( Access = private )
        UnderlyingClassName
        FullSize
    end
    
    methods
        function obj = DisplayHelperOther( name, classname, underlyingclass, fullsize )
            obj.Name                = name;
            obj.ClassName           = classname;
            obj.Value               = []; % unused
            obj.UnderlyingClassName = underlyingclass;
            obj.FullSize            = fullsize;
            obj.IsTruncated         = false;
        end
        
        function doDisp( obj )
            doDisplayOther( obj );
        end
        
        function doDisplay( obj )
            noPageRange    = '';
            noTruncMessage = '';
            obj.nameLine( 'display', noPageRange, noTruncMessage );
            doDisplayOther( obj );
        end
    end

    methods ( Access = private )
        function doDisplayOther( obj )
            % szStr := 4-by-7-by-477-by-
            szStr   = sprintf( '%d-by-', obj.FullSize );
            szStr   = szStr(1:end-4);

            fprintf( 1, '    distributed object of size [%s] with underlying class: %s\n%s', ...
                     szStr, obj.UnderlyingClassName, obj.separator() );
        end
    end
    
    methods ( Access = protected )
        function res = formatEndTruncationMsg( obj ) %#ok<MANU> - match interface
        % "other" arrays are never truncated
            res = '';
        end
    end
    
end
