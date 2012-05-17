function removeOutputs(this,Ports) 
% REMOVEOUTPUTS  method to remove output ports from a SISOTOOL model
% object.
%
% Input:
%    Ports - a vector of indices of ports to remove or a vector of SISOTOOL
%            port objects to remove.
%
% As SISOTOOL output ports cannot be removed from a SISOTOOL model this method 
% is a no-op, but is required for consistency with the model API.
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:41 $

ctrlMsgUtils.warning('SLControllib:modelpack:stWarnRemoveOutput')