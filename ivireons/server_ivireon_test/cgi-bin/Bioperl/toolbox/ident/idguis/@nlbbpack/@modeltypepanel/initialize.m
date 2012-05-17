function initialize(this)
% initialize modeltypepanel object's properties

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:12:38 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% Get handle to model type combo
h = this.jMainPanel; %main java panel for this object
this.jModelStructureCombo = h.getModelStructureCombo;
this.jModelNameLabel = h.getNameLabel;
this.jModelNameEditLabel = h.getModelNameEditLabel;
this.jInitialModelButton = h.getInitialModelButton;
this.InitModelDialog = nlutilspack.initmodeldialog(this);

this.NlarxPanel = nlbbpack.nlarxpanel(h.getInstanceOfNlarxPanel);
this.NlhwPanel  = nlbbpack.nlhwpanel(h.getInstanceOfNlhwPanel);

% initialize widgets
%modname = nlutilspack.generateUniqueModelName('idnlarx');
%this.ModelName = modname;

% Set Data fields
fnames = cell(this.jMainPanel.getKnownModelTypes);
a = struct('ModelName','');
this.Data = struct('StructureIndex',1,fnames{1},a,fnames{2},a);
this.Data.(fnames{1}).ModelName = nlutilspack.generateUniqueModelName(fnames{1});
this.Data.(fnames{2}).ModelName = nlutilspack.generateUniqueModelName(fnames{2});

%set idnlarx ModelName
this.jMainPanel.setModelName(java.lang.String(this.Data.(fnames{1}).ModelName)); 

% attach listeners to the java controls 
this.attachListeners;
