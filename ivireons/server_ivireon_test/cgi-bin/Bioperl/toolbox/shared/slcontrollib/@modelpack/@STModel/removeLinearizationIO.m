function removeLinearizationIO(this,Ports) 
% REMOVELINEARIZATIONIO  method to remove linearization ports from a
% SISOTOOL model object
%
% Inputs:
%     Ports -  a vector of indices of ports to remove or a vector of SISOTOOL
%            linearization objects to remove.
%
% As SISOTOOL linearization ports cannot be removed from a SISOTOOL model this method 
% is a no-op, but is required for consistency with the model API.
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/09/18 02:28:40 $

ctrlMsgUtils.warning('SLControllib:modelpack:stWarnRemoveLinearizationIO')