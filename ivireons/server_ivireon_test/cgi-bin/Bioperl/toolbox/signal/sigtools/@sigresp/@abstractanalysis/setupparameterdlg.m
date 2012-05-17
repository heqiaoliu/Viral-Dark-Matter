function varargout = setupparameterdlg(this, varargin)
%SETUPPARAMETERDLG Setup the parameter dlg for this filtresp

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2007/12/14 15:20:52 $

error(nargchk(1,2,nargin,'struct'));

hPrm = getparameter(this);
hDlg = getcomponent(this, '-class', 'siggui.parameterdlg');

if nargin > 1,
    if isempty(hDlg),
        hDlg = varargin{1};
        addcomponent(this, hDlg);
    else
        hDlg = varargin{1};
    end
        
    set(hDlg, 'Parameters', hPrm);
elseif isempty(hDlg),
    hDlg = siggui.parameterdlg(hPrm);
    set(hDlg, 'Tool', gettoolname(this));
    addcomponent(this, hDlg);
end

% Set the figure title and frame label.
set(hDlg, 'Name', 'Analysis Parameters');
set(hDlg, 'Label', get(this, 'Name'));

attachprmdlglistener(this, hDlg);

lclparameter_listener(this, []);

if ~isrendered(hDlg),
    render(hDlg);
    hDlg.centerdlgonfig(this);
    set(hDlg, 'Visible','On');
    figure(hDlg.FigureHandle);
end

l = handle.listener(this, [this.findprop('DisabledParameters'), ...
    this.findprop('StaticParameters')], 'PropertyPostSet', @lclparameter_listener);

set(l, 'CallbackTarget', this);
setappdata(hDlg.FigureHandle, 'filtresp_listener', l);

if nargout, varargout = {hDlg}; end

% ---------------------------------------------------------------------
function lclparameter_listener(this, eventData)

hDlg = getcomponent(this, '-class', 'siggui.parameterdlg');

set(hDlg, ...
    'DisabledParameters', get(this, 'DisabledParameters'), ...
    'StaticParameters', get(this, 'StaticParameters'));

% [EOF]
