classdef AbstractDataHandler < handle
    %ABSTRACTDATAHANDLER Define the AbstractDataHandler class.

        
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $      $Date: 2010/03/31 18:40:55 $


    properties
        
        % Indicates instantiation status of data source object
        % Initialized to FAILURE as the default
        ErrorStatus = 'success'; % 'success','failure','cancel'
        ErrorMsg = '';

        Source = []; % uiscopes.AbstractSource

        % userdata: undefined storage area (mxArray)
        UserData = [];
    end
    
    properties (SetAccess = protected)
        Data = [];
    end
    
    methods
        function this = AbstractDataHandler(srcObj)
            % Initialize reference to parent
            this.Source = srcObj;
        end
        
        function close(this)
            
            % Close data connection
            disconnectData(this);
        end
        function args = commandLineArgs(this) %#ok
            args = '';
        end
        function disconnectData(this) %#ok
            % NO OP
        end
        function message = emptyFrameMsg(this) %#ok
            message = 'No data (data size is 0x0)';
        end

        function exportFrameName = getExportFrameName(this) %#ok
            exportFrameName = 'Frame';
        end
        function setProperty(this, prop, value) %#ok
            % NO OP
        end
        function resetData(this) %#ok<MANU>
            %NO OP. This should be overloaded by derived classes if needed.
        end
    end
end
