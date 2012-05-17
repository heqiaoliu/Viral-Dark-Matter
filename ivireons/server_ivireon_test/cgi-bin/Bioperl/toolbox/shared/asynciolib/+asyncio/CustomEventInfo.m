classdef CustomEventInfo < event.EventData
% Information associated with the Custom event of a Channel.

% Authors: DTL
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

    properties
        Type  % A string specified by the device adaptor.
        Data  % Any value specified by the device adaptor.
    end
    
    methods
        function obj = CustomEventInfo(type, data)
        % Constructor
            obj.Type = type;
            obj.Data = data;
        end
    end
end

