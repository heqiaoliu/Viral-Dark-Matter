function edit(this,h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Initialize prop editor
h.initialize(this)

%% Add panels
h.axespanel(this,'X');
h.axespanel(this,'Y');
s = struct('charlist',{{'Best fit line','tsguis.regLineData','tsguis.regLineView'}},...
    'additionalDataProps',{{}},'additionalDataPropDefaults',{{}},'additionalHeadings',{{}});
h.charpanel(this,s);