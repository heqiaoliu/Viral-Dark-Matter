function schema

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:17 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'CardPanelViewer');

% The visibility of this widget
p = schema.prop(c,'Visible','MATLAB array');
p.SetFunction = @LocalSetVisibility;
p.GetFunction = @LocalGetVisibility;

% Handle of the dialog frame
p = schema.prop(c,'CardPanels','MATLAB array');

% Card panel Properties Cell array of property pairs
p = schema.prop(c,'CardPanelBorderProperties','MATLAB array');
p.FactoryValue = {'BorderType', 'none'};
p.SetFunction = @LocalSetBorderProps;

% The index of current cardpanel
p = schema.prop(c,'Index','double');
p.SetFunction = @LocalSetIndex;
% Main uipanel container
p = schema.prop(c,'MainPanel','MATLAB array');

% CardPanelPosition in MainPanel
p = schema.prop(c,'CardPosition','MATLAB array');
p.SetFunction = @LocalSetCardPosition;
p.FactoryValue = [0,0.1,1,.9];


% Listeners
p = schema.prop(c,'Listeners','MATLAB array');
p = schema.prop(c,'ButtonPanelListeners','MATLAB array');


%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = LocalGetVisibility(this, ValueStored)
% Get visibility of main panel
Value = get(this.MainPanel,'visible');


function v = LocalSetVisibility(this,v)
% Set visibility of main panel
set(this.MainPanel,'visible',v);

function v = LocalSetCardPosition(this,v)
% Set CardPanelPosition
if ~isempty(this.CardPanels)
    set(this.CardPanels,'Position',v)
end

function v = LocalSetIndex(this,v)
% Set LocalSetIndex
ncp = length(this.CardPanels);
if ~isempty(ncp)
    set(this.CardPanels(v==[1:ncp]),'Visible','on')
    set(this.CardPanels(v~=[1:ncp]),'Visible','off')
end


function v = LocalSetBorderProps(this,v)
% Set visibility of main panel
if ~isempty(this.CardPanels)
    set(this.CardPanels,v{:});
end
