function cfg = getCurrentConfig(this) 
% GETCURRENTCONFIG  method to return current model configuration
%
% As SISOTOOL does not have a configuration object this method returns a
% default structure with the fields necessary to perform a SISOTOOL time
% domain siumulation using the simulate model API method.
%

% Author(s): A. Stothert 01-Aug-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:40:19 $

idx              = find(strcmp(this.IOs.getType,'Input'),1);
cfg              = modelpack.STConfig;
cfg.ActiveInputs = this.IOs(idx); 
cfg.InputType    = 'step';

