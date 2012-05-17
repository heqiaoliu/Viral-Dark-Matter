function hPort = addLinearizationIO(this,Ports) 
% ADDLINEARIZATIONIO  methods to add a linearization port to a SISOTOOL
% model object.
%
% Inputs:
%    Ports - a vector of SISOTOOL linearization ports
%
% As SISOTOOL linearization ports cannot be added to a SISOTOOL model this method 
% is a no-op, but is required for consistency with the model API.
%

% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/09/18 02:28:05 $

hPort = [];
ctrlMsgUtils.warning('SLControllib:modelpack:stWarnAddLinearizationIO')