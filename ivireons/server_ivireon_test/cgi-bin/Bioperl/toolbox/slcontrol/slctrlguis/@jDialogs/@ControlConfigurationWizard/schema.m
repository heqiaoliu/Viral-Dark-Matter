function schema
% Defines properties for control design configuration wizard.

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/12/14 15:28:27 $

% Register class 
pk = findpackage('jDialogs');
c = schema.class(pk,'ControlConfigurationWizard');

% Basic properties
p = schema.prop(c,'ind_current','MATLAB array');
p = schema.prop(c,'WizardPanels','MATLAB array');
p = schema.prop(c,'frame','MATLAB array');
p = schema.prop(c,'Handles','MATLAB array');
p = schema.prop(c,'SISOTaskNode','MATLAB array');
p = schema.prop(c,'loopdata','MATLAB array');