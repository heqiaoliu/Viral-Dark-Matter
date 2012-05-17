classdef AbstractSLHandler < uiscopes.AbstractDataHandler
    %ABSTRACTSLHANDLER Define the AbstractSLHandler class.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.9 $  $Date: 2010/03/31 18:40:38 $
    
    methods
        function this = AbstractSLHandler(srcObj)
            this@uiscopes.AbstractDataHandler(srcObj);
        end
        
        % -----------------------------------------------------------------
        function args = commandLineArgs(this)
            args = commandLineArgs(this.Source.SLConnectMgr);
        end
        
        % -----------------------------------------------------------------
        function resetData(~)
            % Reset data when simulation is restarted.
                    
            % NO OP, overload this method if you need to perform an
            % operation on the data.
            
        end
        
        % -----------------------------------------------------------------
        function [b, exception] = validateSource(~)
            
            b = true;
            exception = MException.empty;
            
        end
        
        % -----------------------------------------------------------------
        function varName = getExportFrameName(this)
            hSrc = this.Source;
            varName = sprintf('%s_%.3f', hSrc.NameShort, getTimeOfDisplayData(hSrc));
            varName = uiservices.generateVariableName(varName);
        end
        
        % -----------------------------------------------------------------
        function msg = emptyFrameMsg(this) %#ok
            %EmptyFrameMsg Text message indicating likely cause of 0x0 video frame size
            %   Overloaded method for DataConnectSimulink.
            
            % This message should never appear until
            % Simulink supports empty signals
            msg = 'Frame contains no data (size is 0x0)';
        end
    end
end
