%DisplayHelperInvalid - helper class for displaying invalid distributed
%arrays

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/07/18 15:50:44 $
classdef DisplayHelperInvalid < distributedutil.DisplayHelper
    
    properties (Access = private)
        WhyInvalidMessage = '';
    end
    
    methods 
        function obj = DisplayHelperInvalid( name, classname, msg )
            obj.Name                = name;
            obj.ClassName           = classname;
            obj.Value               = []; % unused
            obj.IsTruncated         = false;
            obj.WhyInvalidMessage   = msg;
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
            fprintf( 1, '    Invalid distributed array%s\n%s', ...
                     obj.WhyInvalidMessage, obj.separator() );
        end
    end

    methods ( Access = protected )
        function res = formatEndTruncationMsg( ~ )
        % "other" arrays are never truncated
            res = '';
        end
    end
end
