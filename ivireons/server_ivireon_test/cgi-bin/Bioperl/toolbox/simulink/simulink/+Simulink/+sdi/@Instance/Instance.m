classdef Instance
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    methods (Static = true)
        
        function result = getEngine()
            persistent storage;
            
            if isempty(storage)
                storage = Simulink.sdi.SDIEngine;
            end;
            
            result = storage;
        end
        
        function varargout = record(varargin)
            if(nargin == 1)
                if(varargin{1})
                    setappdata(0, 'sdi_record', true);
                else
                    setappdata(0, 'sdi_record', false);
                end
                return;
            else
                if ~isappdata(0, 'sdi_record')
                    storage = false;
                else
                    storage = getappdata(0, 'sdi_record');
                end
                varargout{1} = storage;
            end
        end 
        
        function result = getMainGUI(varargin)
                                    
            if (nargin > 0 && ~isappdata(0, 'SDIGUI'))
                result = [];
                return;
            end
            
            if ~isappdata(0, 'SDIGUI')
                SDIEngine = Simulink.sdi.SDIEngine();
                storage   = Simulink.sdi.GUIMain(SDIEngine);
                setappdata(0, 'SDIGUI', storage);
            else
                storage = getappdata(0, 'SDIGUI');
            end
            
            result = storage;
        end
        
        function open()
            SDIGUIInstance = Simulink.sdi.Instance.getMainGUI();
            SDIGUIInstance.Show();
        end
        
    end % methods
end % classdef