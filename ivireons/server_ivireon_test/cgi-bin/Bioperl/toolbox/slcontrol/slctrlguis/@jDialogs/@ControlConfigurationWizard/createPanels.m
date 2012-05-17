function createPanels(this) 
% CREATEPANELS  Create the default panels for the wizard.
%
 
% Author(s): John W. Glass 10-Aug-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:27:44 $

% Make the tool configuration wizard panel
WizardPanels(1) = jDialogs.PickToolPanel();
  
% Make the select SISOTOOLView panel
WizardPanels(2) = jDialogs.SelectDesignViewsPanel(this);

% Make the select Analysis plots panel
WizardPanels(3) = jDialogs.SelectAnalysisPlotsPanel(this);

this.WizardPanels = WizardPanels;