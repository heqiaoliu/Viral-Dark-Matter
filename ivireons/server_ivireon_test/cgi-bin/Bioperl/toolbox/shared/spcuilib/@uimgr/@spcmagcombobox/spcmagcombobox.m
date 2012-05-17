function this = spcmagcombobox(varargin)
%SPCMAGCOMBOBOX Constructor for spcmagcombobox object.
%   SPCMAGCOMBOBOX(NAME,PLACE) creates an SPCMAGCOMBOBOX UIMgr object, sets
%   the name, and the button rendering placement.
%   SPCMAGCOMBOBOX(NAME) sets the placement to 0.
%
%   % Example:
%
%     hMagComboBox = uimgr.spcmagcombobox('MagCombo');
%
%   % where the argument is the name to use for the new UIMgr node

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/08/14 04:07:21 $

% Allow subclass to invoke this directly
this = uimgr.spcmagcombobox;

% This object does not support a user-specified widget function;
% the spctoggletool always instantiates an spcwidgets.uitoggletool.
this.allowWidgetFcnArg = false;

% We always create a uitoggletool widget every time we render
this.WidgetFcn = @(this) createMagCombo(this);
this.StateName = 'SelectedItem';

% Continue with standard item instantiation
this.uibutton(varargin{:});

% -----------------------------
function hWidget = createMagCombo(this)
% Create the spcwidgets.uimagcombobox widget

% Setting the tag name of the uitoggletool button is not essential.
% It is done for possible future use, and to support testing.
hWidget = spcwidgets.MagCombobox(this.GraphicalParent,'Tag', [class(this), '_', this.name]);

if ~isempty(this.ScrollPanelAPI)
    hWidget.setScrollPanel(this.ScrollPanelAPI)
end

% [EOF]
