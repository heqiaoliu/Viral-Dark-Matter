function setCurrentConfig(this,NewCfg) 
% SETCURRENTCONFIG  method to set SISTOOL model configuration
%
%Inputs:
%     NewCfg -  a SISOTOOL configuration object.
%
% As SISOTOOL cannot be cobnfigured from the command this method 
% is a no-op, but is required for consistency with the model API.
%

% Author(s): A. Stothert 01-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:44 $

ctrlMsgUtils.warning('SLControllib:modelpack:stWarnSetConfiguration')