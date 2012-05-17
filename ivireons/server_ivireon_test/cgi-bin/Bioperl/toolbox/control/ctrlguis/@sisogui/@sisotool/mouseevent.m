function mouseevent(sisodb,EventName)
%MOUSEEVENT  Processes mouse events.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2005/12/22 17:44:09 $

% REVISIT: used only for WBM, waiting for local events...
if strcmp(EventName,'wbm')  
    % Pass event down to children and give right of way if any child is taker
    Children = find(sisodb,'-depth',1);  % warning: 1st entry = sisodb
    for ct=2:length(Children)
        if mouseevent(Children(ct),EventName)
            return
        end
    end
    
    % Window button motion
    if ~strcmp(get(sisodb.Figure,'Pointer'),'arrow')
        set(sisodb.Figure,'Pointer','arrow');
    end
    
    % Post status
    sisodb.EventManager.poststatus(sisodb.EventManager.Status);
end
