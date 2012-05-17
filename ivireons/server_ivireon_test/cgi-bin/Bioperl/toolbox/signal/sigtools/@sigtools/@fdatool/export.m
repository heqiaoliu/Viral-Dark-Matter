function varargout = export(this)
%EXPORT Create an export dialog for fdatool

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.36.4.5 $  $Date: 2005/12/22 19:04:50 $

hXP = getcomponent(this, '-class', 'sigio.export');

if isempty(hXP),
    
    % Create the export dialog
    hXP = sigio.export(getfilter(this));

    % Define contextsensitive help
    set(hXP,'CSHelpTag','fdatool_exportto_frame');
%     jsun - set the flag for not exporting to sptool
    if this.launchedBySPTool == true
        set(hXP,'ExcludeItem','SPTool');
    end

    addcomponent(this,hXP);
    hU = siggetappdata(this.FigureHandle, 'siggui', 'undomanager', 'handle');
    l = [ ...
            handle.listener(this, 'FilterUpdated', {@local_filter_listener, this}) ...
            handle.listener(hU, 'UndoPerformed', {@local_filter_listener, this}) ...
            handle.listener(hU, 'RedoPerformed', {@local_filter_listener, this}) ...
        ];
    set(l, 'CallbackTarget', hXP);
    p = schema.prop(hXP, 'fdatool_filter_listener', 'handle.listener vector');
    set(hXP, 'fdatool_filter_listener', l);
    set(p, 'AccessFlags.PublicSet', 'Off', 'AccessFlags.PublicGet', 'Off');
end

% Render the Export dialog (figure).
if ~isrendered(hXP),
    render(hXP);
    fdaddcontextmenu(hXP.FigureHandle, handles2vector(hXP), 'fdatool_exportto_frame');
    centerdlgonfig(hXP, this);
end

set(hXP, 'Visible', 'On');
figure(hXP.FigureHandle);

if nargout,
    varargout = {hXP};
end

% ----------------------------------------------------------------------
function local_filter_listener(hXP, eventData, this)

filtobj = getfilter(this);

if ~isequal(filtobj, hXP.Data.elementat(1)),
    hXP.Data = filtobj;
end

% [EOF]
