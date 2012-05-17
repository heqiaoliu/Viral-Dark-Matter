function this = ExportSimulinkIC(model,op,defaultname) 
% EXPORTSIMULINKIC  Constructor for the dialog class
%
 
% Author(s): John W. Glass 28-Mar-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/05/27 14:25:58 $

%% Call the constructor
this = jDialogs.ExportSimulinkIC;

%% Store the properties
this.Model = model;
this.OperatingPoint = op;

%% Build the GUI
this.buildgui(defaultname)