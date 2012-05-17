function this = initmodeldialog(owner)
% Initial model specification in Nonlinear Models GUI
% owner: model type panel (udd) handle

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:35 $

import com.mathworks.toolbox.ident.nnbbgui.*;
import com.mathworks.mwswing.MJOptionPane;

this = nlutilspack.initmodeldialog;
this.Owner = owner;
frame = MJOptionPane.getFrameForComponent(owner.jMainPanel);
this.jOwnerFrame = frame;
h = InitialModelDialog(frame);
this.jDialog = h;

this.jCheck = h.getCheck;
this.jCombo = h.getCombo;
this.jInfoArea = h.getInfoArea;

% Set Data fields
fnames = cell(owner.jMainPanel.getKnownModelTypes);
a = struct('ExistingModels',{{''}},'SelectionIndex',1);
this.Data = struct('StructureIndex',1,fnames{1},a,fnames{2},a);

NamesOnly = true;
strict = false; % do not care for mismatch in I/O names (as long as DIMs match)
x1 = nlutilspack.getAllCompatibleModels(fnames{1},NamesOnly,strict); 
x2 = nlutilspack.getAllCompatibleModels(fnames{2},NamesOnly,strict); 
this.Data.(fnames{1}).ExistingModels = x1; 
this.Data.(fnames{2}).ExistingModels = x2; 

this.attachListeners;
