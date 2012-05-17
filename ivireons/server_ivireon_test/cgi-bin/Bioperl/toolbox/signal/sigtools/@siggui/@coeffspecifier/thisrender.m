function thisrender(this, varargin)
%RENDER Render the coefficient Specifier

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.18.4.10 $  $Date: 2009/07/14 04:03:34 $

framePos = parserenderinputs(this, varargin{:});
if isempty(framePos),
    framePos = [20 20 450 200];
end

structureSelector(this, framePos);

% Render the Coefficient Labels
importLabels(this);

% Render the Edit boxes where the coefficients will be specified.
importEditBoxes(this,framePos);

% Render the "Clear" push buttons which clear the coefficient edit boxes.
importClearPushBtns(this);

sosCheckbox(this);

structure_listener(this, []);
prop_listener(this, 'sos');

set(handles2vector(this),'Units','Normalized');
cshelpcontextmenu(this, 'fdatool_ALL_import_structures');

% Create the constructors
l = [handle.listener(this, this.findprop('Coefficients'),...
    'PropertyPostSet', @update_editboxes); ...
    handle.listener(this, this.findprop('SelectedStructure'),...
    'PropertyPostSet', @structure_listener); ...
    handle.listener(this, this.findprop('SOS'),...
    'PropertyPostSet', @sos_listener)];

% Set CallbackTarget to the object so that we can use methods
set(l,'CallbackTarget', this);

set(this,'WhenRenderedListeners',l);


%----------------------------------------------------------------------
function structureSelector(this, pos)

bgc   = get(0,'defaultuicontrolbackgroundcolor');
sz    = coeffspecifier_gui_sizes(this);
specs = get(this,'AllStructures');
h     = get(this,'Handles');
hFig  = get(this,'FigureHandle');

fsUiWdth  = largestuiwidth(specs.strs,'popup');

if fsUiWdth > 200*sz.pixf;
    fsUiWdth = 200*sz.pixf;
end

fsLblPos = [pos(1) pos(2)+pos(4)-sz.uh-sz.uuvs fsUiWdth sz.uh];
fsPopPos = fsLblPos - [0 sz.uh 0 0];

% Render the Filter Structure label
h.label = uicontrol(hFig,...
    'Style','text',...
    'HorizontalAlignment', 'Left', ...
    'BackGroundColor',bgc,...
    'Position', fsLblPos,...
    'String','Filter Structure:',...
    'Visible','Off',...
    'Tag','coeffspecifier_lbl');

font = get(0,'defaultuicontrolfontname');
if isunix, font = 'Times'; end

popupstrs = specs.strs;
for indx = 1:length(popupstrs)
    popupstrs{indx} = xlate(popupstrs{indx});
end

% Render the Filter Structure popupmenu
h.selectedstructure = uicontrol(hFig,...
    'Style','Popup',...
    'BackgroundColor','White',...
    'HorizontalAlignment', 'Left', ...
    'FontName', font, ...
    'Position', fsPopPos,...
    'Visible','Off',...
    'String', popupstrs,...
    'Tag','coeffspecifier_popup',...
    'Callback',{@selectedstructure_cb, this, specs.strs});

set(this,'Handles',h);

%----------------------------------------------------------------------
function selectedstructure_cb(hcbo, eventStruct, this, strs) %#ok<INUSL>

indx = get(hcbo, 'Value');

set(this, 'SelectedStructure', strs{indx});

%----------------------------------------------------------------------
function sosCheckbox(this)

h = get(this, 'Handles');

cbs = callbacks(this);
sz  = gui_sizes(this);
pos = get(h.selectedstructure, 'Position');

str = xlate('Import as second-order sections');

pos(2) = pos(2) - sz.uh - sz.uuvs;
pos(3) = max(pos(3), largestuiwidth({str}));

h.sos = uicontrol(this.FigureHandle, ...
    'Style', 'Checkbox', ...
    'Position', pos, ...
    'Tag', 'coeffspecifier_checkbox', ...
    'String', str, ...
    'Visible', 'Off', ...
    'Callback', {cbs.property, this, 'sos'});

set(this, 'Handles', h);

%----------------------------------------------------------------------
function importLabels(this)

% Inputs:
%   this

% Cache uicontrol sizes and figure's background color.
h     = get(this,'Handles');
sz    = coeffspecifier_gui_sizes(this);
bgc   = get(0,'defaultuicontrolbackgroundcolor');
hFig  = get(this,'FigureHandle');

startingPos    = get(h.selectedstructure,'Position');
startingPos(1) = startingPos(1) + startingPos(3) + sz.uuhs;
startingPos(3) = sz.lblwidth;

% Render the edit box labels
for n = 1:2,
    
    h.lbls(n) = uicontrol(hFig,...
        'Style','Text',...
        'BackgroundColor',bgc,...
        'Position', startingPos,...
        'Visible','Off',...
        'Tag',['coeffspecifier_lbl' num2str(n)],...
        'String',num2str(n),...
        'HorizontalAlignment','Right');
    startingPos(2) = startingPos(2) - (sz.uuvs+sz.uh);
end

set(this,'Handles',h);


%----------------------------------------------------------------------
function importEditBoxes(this, frpos)
% IMPORTEDITBOXES Render the Filter Coefficients edit boxes.
%
% Inputs:
%   hFig      - Handle to the Filter Design GUI figure.
%   framePos  - Specify Filter Coefficients frame position.
%   fsPopPos  - Filter Structure popupmenu position.
%
% Outputs:
%  h_ebs   - Handles to the Filter coefficient edit boxes.

% Cache uicontrol sizes and figure's background color
h     = get(this,'Handles');
sz    = coeffspecifier_gui_sizes(this);
hFig  = get(this,'FigureHandle');

startingPos    = get(h.lbls(1),'Position');
startingPos(1) = startingPos(1) + startingPos(3) + sz.uuhs;
startingPos(3) = frpos(3)-startingPos(1)-sz.clwidth-2*sz.uuhs;

% NOTE: The importparams_cbs function updates the figure's userdata
% This callback string is for all Import Coefficients Edit Boxes.
cbs    = callbacks(this);

% Render the maximum number of filter coefficient edit boxes which 
% is four (due to the State-space case) 
for n = 1:2,
    h.ebs(n) = uicontrol(hFig,...
        'Style','Edit',...
        'BackgroundColor','White',...
        'Position', startingPos, ...
        'Visible','Off',...
        'UserData', n, ...
        'HorizontalAlignment','Left',...
        'Tag',['coeffspecifier_editbox' num2str(n)],...
        'String','',...
        'Callback',{cbs.importcoeff_eb, this});
    startingPos(2) = startingPos(2) - (sz.uuvs+sz.uh);
end

set(this,'Handles',h);


%----------------------------------------------------------------------
function importClearPushBtns(this)
% IMPORTCLEARPUSHBTNS  Render the "Clear" push buttons for resetting 
%                      the coefficients edit boxes.
%
% Inputs:
%   hFig      - Handle to the Filter Design GUI figure.
%   framePos  - Specify Filter Coefficients frame position.
%   fsPopPos  - Filter Structure popupmenu position.
%
% Outputs:
%  h_ebs   - Handles to the Filter coefficient edit boxes.

% Cache uicontrol sizes and figure's background color
h     = get(this,'Handles');
sz    = coeffspecifier_gui_sizes(this);
bgc   = get(0,'defaultuicontrolbackgroundcolor');
hFig  = get(this,'FigureHandle');

startingPos    = get(h.ebs(1),'Position');
startingPos(1) = startingPos(1) + startingPos(3) + sz.uuhs;
startingPos(3) = sz.clwidth;

% NOTE: The importparams_cbs function updates the figure's userdata
% This callback string is for all Import Coefficients Edit Boxes.
cbs = callbacks(this);

% Render maximum number of "Clear" push buttons which is four (due to 
% the State-space case) 
for n = 1:2,
    h.clrpbs(n) = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position', startingPos, ...
        'Visible','Off',...
        'UserData', n, ...
        'Tag',['coeffspecifier_clearpb' num2str(n)],...
        'String',sprintf('Clear'),...
        'Callback',{cbs.clearpush_cb, this});
    startingPos(2) = startingPos(2) -(sz.uuvs+sz.uh);
end

set(this,'Handles',h);


%----------------------------------------------------------------------
function sz = coeffspecifier_gui_sizes(this)

sz = gui_sizes(this);

sz.lblwidth = 0;
lbls = get(this, 'Labels');
f    = fieldnames(lbls);
for indx = 1:length(f),
    sz.lblwidth = max([sz.lblwidth largestuiwidth(lbls.(f{indx}))]);
end

sz.ebwidth  = 180 * sz.pixf;
sz.clwidth  = 39 * sz.pixf;

if isunix
    sz.ebwidth = sz.ebwidth - 20*sz.pixf;
end

% [EOF]
