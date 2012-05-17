function clearDataTips(EventSrc,EventData)
%

% CLEARDATATIPS Clear the data tips when axis is clicked. This function is
% set as ButtonDownFcn of the axis and is used by plotting commands such as
% simView and simCompare.

%  Author(s): Erman Korkut 24-Mar-2009
%  Revised: 
%  Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:38 $

% Process event
switch get(ancestor(EventSrc,'figure'),'SelectionType')
    case 'normal'
        % Get the cursor mode object
        hTool = datacursormode(ancestor(EventSrc,'figure'));
        % Clear all data tips
        target = handle(EventSrc);
        if ishghandle(target,'axes')
            removeAllDataCursors(hTool,target);
        end
end
end