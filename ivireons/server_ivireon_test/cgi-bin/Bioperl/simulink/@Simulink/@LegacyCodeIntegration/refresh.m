function refresh(h, modelname)

%   Copyright 2009 The MathWorks, Inc.

h.modelname     = modelname; % In case the model name is updated by saveas
h.simSymbols    = [];
h.rtwSymbols    = [];
h.simSymbolList = {};
h.rtwSymbolList = {};
h.simChecksum   = 0;
h.rtwChecksum   = 0;
h.simFileList   = {};
h.rtwFileList   = {};
h.states        = 0;
h.aliasList     = {};
symbolList = h.getSymbolList(modelname,false);
%symbolList = h.getSymbolList(modelname,true);

% attach to model
set_param(h.modelname,'LegacyCodeIntegration',h);
