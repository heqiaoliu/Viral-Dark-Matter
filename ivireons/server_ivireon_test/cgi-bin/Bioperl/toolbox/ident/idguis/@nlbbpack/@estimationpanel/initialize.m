function initialize(this)
% store handles to widgets and attach listeners 

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:03:58 $

% spawn nonlinear black box gui (java)
import com.mathworks.toolbox.ident.nnbbgui.*;

this.jTable = this.jMainPanel.getTable;
this.jTableModel = this.jMainPanel.getTableModel;
this.jInfoArea = this.jMainPanel.getInfoArea;
this.jEstimationOptionsButton = this.jMainPanel.getEstimationOptionsButton;
this.jRandomizeCheckBox = this.jMainPanel.getRandomizeCheckBox;
this.jReiterateCheckBox = this.jMainPanel.getReiterateCheckBox;

% messenger between optimizer and iteration table
this.OptimMessenger = nlutilspack.optimmessenger;

this.AlgorithmOptions = [nloptionspack.algorithmoptionswithfocus;...
    nloptionspack.algorithmoptionswithx0];

% attach listeners to the java controls 
this.attachListeners;
