function showNoDockedDialogsMsg(dp)
% Optionally show "no docked dialogs" message

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:27 $

if isempty(dp.DockedDialogs)
    % Need a "test fit" of message to get actual extent
    msg = sprintf('(No\ndocked\ndialogs)');
    set(dp.hNoDockedDialogs, ...
        'string',msg, ...
        'vis','off');
    
    % Determine size of msg
    ext = get(dp.hNoDockedDialogs,'ext');
    textWidth = ext(3);
    textHeight = ext(4);
    [~,panelWidth,panelHeight] = getDialogPanelAndSize(dp);
    
    if textWidth > panelWidth || textHeight > panelHeight
        % Panel is too small for message to display
        set(dp.hNoDockedDialogs,'vis','off');
    else
        % Show message centered in empty dialog panel
        x = (panelWidth-textWidth)/2;
        y = (panelHeight-textHeight)/2;
        set(dp.hNoDockedDialogs, ...
            'pos',[x y textWidth textHeight], ...
            'vis','on');
    end
else
    set(dp.hNoDockedDialogs,'vis','off');
end

