function varargout = reordersos(this)
%REORDERSOS   Create a reorder dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:47:00 $

Hd = getfilter(this);

if isa(Hd, 'dfilt.abstractsos'),
    hdlg = getcomponent(this, '-class', 'siggui.sosreorderdlg');
    if isempty(hdlg),
        
        % Create a new reorder dialog
        hdlg = siggui.sosreorderdlg(Hd);
        
        % Add it to FDATool
        addcomponent(this, hdlg);
        
        % Add listeners to the 'FilterUpdated' and 'FilterReordered' events
        % to keep the objects in sync.
        addlistener(this, 'FilterUpdated', {@lclfilterupdated_listener, hdlg});
        l = handle.listener(hdlg, 'FilterReordered', {@lclfilterreordered_listener, hdlg});
        set(l, 'CallbackTarget', this);
        setappdata(this, 'sosreorderlistener', l);
    end
else
    error(generatemsgid('notSOS'), 'Only SOS filters can be reordered.');
end

% If the dialog is unrendered, rerender it.
if ~isrendered(hdlg)
    render(hdlg);
    centerdlgonfig(hdlg, this);
end

set(hdlg, 'Visible', 'On');
figure(hdlg.FigureHandle);

if nargout,
    varargout = {hdlg};
end

% -------------------------------------------------------------------------
function lclfilterupdated_listener(this, eventData, hdlg)

Hd = getfilter(this);
if isa(Hd, 'dfilt.abstractsos')
    enab = this.Enable;
    set(hdlg, 'Filter', Hd);
else
    enab = 'Off';
end

set(hdlg, 'Enable', enab);

% -------------------------------------------------------------------------
function lclfilterreordered_listener(this, eventData, hdlg)

opts.source = 'Reordered SOS';

setfilter(this, get(hdlg, 'Filter'), opts);

% [EOF]
