function this = ControlConfigurationWizard(SISOTaskNode,loopdata) 
% CONTROLCONFIGURATIONWIZARD  Create the control configuration wizard
%
 
% Author(s): John W. Glass 11-Aug-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:27 $

%% Create the object
this = jDialogs.ControlConfigurationWizard;
%% Store the design data
this.loopdata = loopdata;
%% Store the tasknode
this.SISOTaskNode = SISOTaskNode;
%% Build and show the wizard
this.build;