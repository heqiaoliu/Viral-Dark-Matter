function Inputs = getInputs(this,index) 
% GETINPUTS  method to return SISOTOOL model object's input port objects 
%
% inputs = this.getInputs(index)
%
% Input:
%   index - numerical index of inputs to return
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:22 $


Ports = this.IOs;
idx = strcmpi(Ports.getType,'input');
Inputs = Ports(idx);
if nargin == 1 
   %Quick return for all inputs
   return
elseif all(isnumeric(index)) && all(isfinite(index))
   %Indexed
   Inputs = Inputs(index);
else
   ctrlMSgUtils.error('SLControllib:modelpack:errArgumentType','index','finite integer')
end
   