function cbs = callbacks(this)
%CALLBACKS Callbacks for the menus and toolbar buttons of the window GUI.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.6 $  $Date: 2009/03/09 19:35:48 $ 

% This can be a private method

cbs     = siggui_cbs(this);
cbs.new = {@new_cbs, this};
cbs.close = {@close_cbs, this};
cbs.export = {cbs.method, this, @wintool_export};
cbs.preferences = {@preferences_cbs, this};
cbs.pagesetup = {@pagesetup_cbs, this};
cbs.printsetup = {@printsetup_cbs, this};
cbs.printpreview = {cbs.method, this, @printpreview};
cbs.print = {cbs.method, this, @print};
cbs.printtofigure = {@printofigure_cbs, this};
cbs.wintoolhelp = {@wintoolhelp_cbs, this};

%-------------------------------------------------------------------------
function new_cbs(hcbo, eventstruct, this)

wintool;


%-------------------------------------------------------------------------
function close_cbs(hcbo, eventstruct, this)

set(this, 'Visible', 'Off');
delete(this.FigureHandle);
delete(this);


%-------------------------------------------------------------------------
function preferences_cbs(hcbo, eventstruct, this)

preferences;


%-------------------------------------------------------------------------
function pagesetup_cbs(hcbo, eventstruct, this)

hFig = get(this, 'FigureHandle');
pagesetupdlg(hFig);


%-------------------------------------------------------------------------
function printsetup_cbs(hcbo, eventstruct, this)

hFig = get(this, 'FigureHandle');
printdlg('-setup', hFig);

%-------------------------------------------------------------------------
function printpreview(this)

h = getcomponent(this, '-class', 'siggui.winviewer');
inputs = getprintinputs(this);
h.printpreview(inputs{:});


%-------------------------------------------------------------------------
function print(this)

h = getcomponent(this, '-class', 'siggui.winviewer');
inputs = getprintinputs(this);
h.print(inputs{:});


%-------------------------------------------------------------------------
function printofigure_cbs(hcbo, eventstruct, this)
% Launch WVTool

hManag = getcomponent(this, '-class', 'siggui.winmanagement');
winspecs = hManag.Window_list;
selected = hManag.Selection;
currentindex = hManag.Currentwin;

if ~isempty(selected),
    
    hVold = getcomponent(this, '-class', 'siggui.winviewer');
    
    % Instantiate the wvtool object
    hV = sigtools.wvtool(copyparams(get(hVold, 'Parameters')));
    
    set(hV, 'Legend', get(hVold, 'Legend'));
    
    % Render the winview object
    render(hV);
    
    % Add the selected windows to WVTool
    N = length(selected);
    for i = 1:N,
        % Reverse order to keep the color order
        winobjs(i) = get(winspecs(selected(N-i+1)),'Window');
    end

    names = get(winspecs(selected), 'Name');
    if ~iscell(names)
        names = {names};
    end
    % Find current (bold) window
    ind = find(selected==currentindex);
    addwin(hV, winobjs, [], 'Replace', ind, names);
        
    % Turn visibility on
    set(hV, 'Visible', 'on');
end

%-------------------------------------------------------------------------
function wintoolhelp_cbs(hcbo, eventstruct, this)

cbs = wintool_help;
hFig = get(this, 'FigureHandle');
feval(cbs.toolhelp, [], [], hFig);

%-------------------------------------------------------------------------
function inputs = getprintinputs(this)

hFig = get(this, 'FigureHandle');

inputs = {'PaperUnits',  get(hFig, 'PaperUnits'), ...
    'PaperOrientation',  get(hFig, 'PaperOrientation'), ...
    'PaperPosition',     get(hFig, 'PaperPosition'), ...
    'PaperPositionMode', get(hFig, 'PaperPositionMode'), ...
    'PaperSize',         get(hFig, 'PaperSize'), ...
    'PaperType',         get(hFig, 'PaperType')};

%-------------------------------------------------------------------
function h = copyparams(hold)

for i = 1:length(hold),
    h(i) = sigdatatypes.parameter(hold(i).Name, hold(i).Tag, ...
        hold(i).ValidValues, hold(i).Value);
end


% [EOF]
