function edit(view,h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Initialize prop editor
h.initialize(view)

%% Add panels
h.axespanel(view,'Y');
s = struct('charlist',{{'Mean','tsguis.histMeanData','tsguis.histMeanView';...
    'Median','tsguis.histMedianData','tsguis.histMeanView'}},...
    'additionalDataProps',{{}},'additionalDataPropDefaults',...
    {{}},'additionalHeadings',{{}});
h.charpanel(view,s);
view.binpnl(h);