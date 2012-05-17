classdef DialogUpdateEventData < event.EventData
%DIALOGUPDATEEVENTDATA Defines the data that is passed to a listener via
%the notify method.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:08 $

    properties
        UpdatedDialog = [];
    end
    
    methods
        function this = DialogUpdateEventData(dialog)
            this.UpdatedDialog = dialog;
        end
    end    
end

% [EOF]
