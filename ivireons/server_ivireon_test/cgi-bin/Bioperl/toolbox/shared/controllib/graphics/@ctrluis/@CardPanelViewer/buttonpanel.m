function BtnPanel = buttonpanel(this)
% BUTTONPANEL Create the standard button panel for cardpanelviewer

%   Author(s): Craig Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:15 $

BtnPanel = uipanel('parent', this.MainPanel, 'position', [0,0,1,.1]);
B(1,1) = uicontrol('Parent',BtnPanel, ...
     'Units','normalized', ...
    'Position',[0.05 0.1 .1 .7], ...
    'Callback',{@LocalUpdateIndex, this, -1}, ...
    'Enable','off',...
    'String','<<');
B(2,1) = uicontrol('Parent',BtnPanel, ...
    'Units','normalized', ...
    'Position',[0.45 0.1 .1 .7], ...
    'Callback',{@LocalUpdateIndex, this, 1}, ...
    'String','>>');

B(3,1) =  uicontrol('Parent',BtnPanel, ...
    'Style', 'text', ...
    'Units','normalized', ...
    'Position',[.15 0.1-.05 .3 .7], ...
    'String','');


this.ButtonPanelListeners = [handle.listener(this,this.findprop('Index'), ...
    'PropertyPostSet', {@LocalUpdateButtonState, this, B}); ...
    handle.listener(this,this.findprop('CardPanels'), ...
    'PropertyPostSet', {@LocalUpdateButtonState, this, B})];


% ------------------------------------------------------------------------%
% Function: LocalUpdateButtonState
% Purpose:  Updates Button states based on index and number of avaiable
% panels
% ------------------------------------------------------------------------%
function LocalUpdateButtonState(hSrc, event, this, B)

if this.Index > 1 
    DecButton = 'on';
else
    DecButton = 'off';
end

if this.Index < length(this.CardPanels)
    IncButton = 'on';
else
    IncButton = 'off';
end

set(B(1),'Enable', DecButton);
set(B(2),'Enable', IncButton);
set(B(3),'String', sprintf('Architecture %s of %s',num2str(this.Index),num2str(length(this.CardPanels))));

% ------------------------------------------------------------------------%
% Function: LocalUpdateIndex
% Purpose:  Updates the index for the panel to view when button is pressed
% ------------------------------------------------------------------------%    
function LocalUpdateIndex(hSrc, event, this, Value)

this.Index = this.Index + Value;










