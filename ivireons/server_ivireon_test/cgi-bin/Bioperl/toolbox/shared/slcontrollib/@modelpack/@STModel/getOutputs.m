function Outputs = getOutputs(this,index) 
% GETOUTPUTS  method to return SISOTOOL model object's output port objects 
%
% ports = this.getOutputs(index)
%
% Input:
%   index - numerical index of output ports to return
%

 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:25 $

Ports = this.IOs;
idx = strcmpi(Ports.getType,'output');
Outputs = Ports(idx);
if nargin == 1 
   %Quick return for all outputs
   return
elseif all(isnumeric(index)) && all(isfinite(index))
   %Indexed
   Outputs = Outputs(index);
else
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','index','finite integer')
end