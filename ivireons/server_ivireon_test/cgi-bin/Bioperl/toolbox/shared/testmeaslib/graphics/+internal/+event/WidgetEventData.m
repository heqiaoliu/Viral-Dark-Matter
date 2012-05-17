classdef WidgetEventData < event.EventData
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.1 $ $Date: 2010/03/04 16:32:09 $
    % --------------------------------------------------------------------
    properties
        Data
    end
    
    methods
        function obj = WidgetEventData(data)
            obj.Data = data;
        end
    end
end
