function edit(view,h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Listeners which keep the panels udpated. These are @viewplot
%% specific
% h.Listeners = [h.Listeners;...
%      handle.listener(view.AxesGrid,'Viewchanged',@(es,ed) axespanel(h,view,'Y')); ...
%      handle.listener(view.AxesGrid,'Viewchanged',@(es,ed) updatechartable(view,h)); ...
%      handle.listener(view.AxesGrid,view.AxesGrid.findprop('XUnits'),'PropertyPreSet',...
%                    {@localUpdateCharUnits view h})];

h.Listeners = handle.listener(view.AxesGrid,view.AxesGrid.findprop('XUnits'),'PropertyPreSet',...
                   {@localUpdateCharUnits view h});

%% Build the @ploteditor
h.initialize(view)

%% Add panels
h.axespanel(view,'Y',xlate('Use a log scale for periodogram Y values')); 
s = struct('charlist',{{'Variance','tsguis.tsCharVarData','tsguis.tsCharVarView'}},...
    'additionalDataProps',{{'StartFreq','EndFreq'}},'additionalDataPropDefaults',...
    {{'0','0.5'}},'additionalHeadings',{{xlate('Low limit'),xlate('High limit')}});
h.charpanel(view,s);
view.freqpnl(h);

function localUpdateCharUnits(es,ed,h,thispropedit)

%% Callback for changes in the plot time units which will update the
%% Start and End Times on the @timeplot char panel
drawnow
timeunitconv = tsunitconv(sprintf('%ss',ed.NewValue(5:end)),...
    sprintf('%ss',h.AxesGrid.XUnits(5:end)));
updatechartable(h,thispropedit,1/timeunitconv)

