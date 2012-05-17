function schema
% Defines properties for @tab class (single tab panel for tabbed dialog)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:10 $
c = schema.class(findpackage('ctrluis'),'tabpanel');

% Properties
% RE: Assumes the figure units are fixed
p = schema.prop(c,'Callback','MATLAB array');% Tab callback
p.SetFunction = @LocalSetCallback;
schema.prop(c,'Children','MATLAB array');    % Tab children
p = schema.prop(c,'PanelHeight','double');   % Panel height in figure units
p.GetFunction = @LocalGetPanelHeight;
schema.prop(c,'Parent','handle');            % Parent figure
p = schema.prop(c,'Position','MATLAB array');% Tab position in figure units
p.FactoryValue = [10 10 50 30];
p = schema.prop(c,'Selected','on/off');      % Selection state
p.SetFunction = @LocalSetSelected;
p = schema.prop(c,'String','string');        % Tab label
p.SetFunction = @LocalSetString;
schema.prop(c,'TabOffset','double');         % Tab offset from left panel edge (in characters)
p = schema.prop(c,'TabWidth','double');      % Tab width in characters (-1 = auto)
p.GetFunction = @LocalGetTabWidth;
p = schema.prop(c,'TabHeight','double');     % Tab height in characters (-1 = auto)
p.FactoryValue = 2;
p = schema.prop(c,'Visible','on/off');       % Visibility state
p.SetFunction = @LocalSetVisible;
p.FactoryValue = 'on';

schema.prop(c,'Label','MATLAB array');        % Tab label
schema.prop(c,'Panel','MATLAB array');        % Panel borders
schema.prop(c,'TabLeftEdge','MATLAB array');  % Tab left edge
schema.prop(c,'TabRightEdge','MATLAB array'); % Tab right edge
schema.prop(c,'TabTopEdge','MATLAB array');   % Tab top edge
schema.prop(c,'Pix2Unit','MATLAB array');     % Pixel/fig unit ratios
schema.prop(c,'Char2Unit','MATLAB array');    % Char/fig unit ratios
schema.prop(c,'Listeners','handle vector');   % Char/fig unit ratios
%set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off')

%----------- Local Functions ---------------------

function cb = LocalSetCallback(this,cb)
set(this.Label,'ButtonDownFcn',cb)

function v = LocalGetPanelHeight(this,v)
if ~isempty(this.Char2Unit)
   v = this.Position(4) - this.Char2Unit(2) * this.TabHeight;
end

function v = LocalGetTabWidth(this,v)
v = length(this.String)+6; % in characters

function str = LocalSetString(this,str)
set(this.Label,'String',str)

function onoff = LocalSetVisible(this,onoff)
set([this.Label;this.TabLeftEdge;this.TabRightEdge;this.TabTopEdge],'Visible',onoff)

function onoff = LocalSetSelected(this,onoff)
set([this.Panel;this.Children],'Visible',onoff)
set(findobj(this.Children,'Type','axes'),'ContentsVisible',onoff)
% see also PostSetListener for updating panel layout
