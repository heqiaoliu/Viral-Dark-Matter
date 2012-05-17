function OptionsStruct = getOptionsStruct(this)
% GETOPTIONSSTRUCT  Get the options structure for the Simulink Control
% Design Task.
%
 
% Author(s): John W. Glass 21-Sep-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:43:55 $

tasknode = this.up;
OptionsStruct = tasknode.OptionsStruct;