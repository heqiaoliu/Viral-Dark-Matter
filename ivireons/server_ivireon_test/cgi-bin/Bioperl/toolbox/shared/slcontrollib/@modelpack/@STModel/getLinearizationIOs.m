function Ports = getLinearizationIOs(this,index) 
% GETLINEARIZATIONIOS  method to return SISOTOOL model object's 
% linearization port objects.
%
% ports = this.getLinearizationIOs(index)
%
% Input:
%   index - numerical index of linearization ports to return
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/09/18 02:28:23 $

Ports = this.LinearizationIOs;
if nargin == 1 
   %Quick return for all outputs
   return
elseif all(isnumeric(index)) && all(isfinite(index))
   %Indexed
   Ports = Ports(index);
else
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','index','finite integer');
end