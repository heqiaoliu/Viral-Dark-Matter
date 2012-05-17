function close(this,optstr)
%CLOSE Closes the FDATool GUI.
%   CLOSE(H) Closes the FDATool session specified by the this and deletes
%   all figures associated with the GUI.  If the session has  not been
%   saved the user will be prompted to save the session.

%   Author(s): P. Pacheco
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.17.4.8 $  $Date: 2009/04/21 04:36:57 $

error(nargchk(1,2,nargin,'struct'));

% Check the optional input and make sure that it is valid.
if nargin < 2 | ~ischar(optstr), optstr = ''; end

hFig = get(this,'figureHandle');

% If called with "force" close the figure without prompting.
% Skip closing if Cancel button is pressed on save dialog.
if strcmpi(optstr,'force') | save_if_dirty(this,'closing'),
    
    htip = getappdata(this, 'tipoftheday');
    if ishghandle(htip)
        delete(htip);
    end
    
    set(hFig, 'Visible', 'Off');

    % Make sure that listeners don't fire.
    set(this, 'Listeners', []);
    set(this, 'ApplicationData', []);

    send(this,'CloseDialog',handle.EventData(this,'CloseDialog'));

    hComps = allchild(this);
    delete(hComps);
            
    delete(this.FigureHandle);
    delete(this);

    clear this;
end

% [EOF]
