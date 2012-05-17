function handleButtons(this,buttonStr)
%HANDLEBUTTONS Handle buttons in Frame Rate dialog.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:58 $

switch lower(buttonStr)
    case 'dropframescheckbox'
        % "Drop frames as needed" checkbox pressed
        %
        % Force dialog to refresh, in order to show/hide
        %   widgets that have become visible/invisible
        % Also, force a resize on the dialog, to adjust
        %   for newly added/removed widgets
        %this.show;  % resets title, etc
        refresh(this.dialog);
        resetSize(this.dialog,1)
        
    otherwise
        error(generatemsgid('InvalidButtonName'), ...
            'unhandled button in frame rate dialog')
end

% [EOF]
