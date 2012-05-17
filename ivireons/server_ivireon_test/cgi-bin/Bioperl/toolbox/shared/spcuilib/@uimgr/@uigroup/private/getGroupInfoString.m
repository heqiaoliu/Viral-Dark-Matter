function s = getGroupInfoString(ch)
%getGroupInfoString Return group info string.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:55:05 $

% Does it have a WidgetFcn, and an hWidget handle?
wfcn = '';
if ~isempty(ch.WidgetFcn)
    %fInfo = functions(ch.WidgetFcn);
    %wfcn = ['Widget="' fInfo.function '" '];
    wfcn = 'Widget';
    hWidget = ch.hWidget;
    if ~isempty(hWidget) && uimgr.isHandle(hWidget)
        % Get separator from widget
        sepStr = '';
        if isprop(hWidget, 'Separator')
            if strcmp(get(hWidget,'Separator'),'on')
                sepStr = ',sep';
            end
        else
            sepStr = ',<no sep support>';
        end
        wren = sprintf('(rendered%s) ',sepStr);
    else
        % Get separator from object
        if strcmp(ch.Separator,'on'),
            sepStr=',sep';
        else
            sepStr='';
        end
        wren = sprintf('(unrendered%s) ',sepStr);
    end
    wfcn = [wfcn wren];
end

s = sprintf('''%s'' Place=%g %s%s', ...
    ch.Name, ch.ActualPlacement, wfcn, class(ch) );

% [EOF]
