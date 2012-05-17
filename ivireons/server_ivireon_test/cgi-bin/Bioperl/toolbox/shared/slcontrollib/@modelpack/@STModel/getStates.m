function States = getStates(this,index) 
% GETSTATES  method to return SISOTOOL model object's state objects 
%
% states = this.getStates(index)
%
% Input:
%   index - numerical index of states to return
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:33 $

States = this.States;
if nargin == 1 
   %Quick return for all outputs
   return
elseif all(isnumeric(index)) && all(isfinite(index))
   %Indexed
   States = States(index);
else
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','index','finite integer');
end