function hPort = addOutput(this,Port) 
% ADDOUTPUT  method to add an Output port to a SISOTOOL model object. 
%
% Input:
%     Port - a modelpack.STPort object
%
% As SISOTOOL output ports cannot be added to a SISOTOOL model this method 
% is a no-op, but is required for consistency with the model API.
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:07 $

hPort = [];
ctrlMsgUtils.warning('SLControllib:modelpack:stWarnAddOutput')