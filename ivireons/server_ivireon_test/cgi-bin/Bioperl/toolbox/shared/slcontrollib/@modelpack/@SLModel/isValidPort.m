function b = isValidPort(this,PortIDs) 
% ISVALIDPORT check that ports are valid for this model
%
% b = this.isValidPort(PortIDs)
%
% Inputs:
%   PortIDs - a vector of modepack.SLPortID objects
% Outputs:
%   b - a vector of logicals indicating whether the passed ports are valid
%       for this model
 
% Author(s): A. Stothert 11-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:56:57 $

if ~isa(PortIDs,'modelpack.SLPortID')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','PortIDs','modelpack.SLPortID')
end

nPorts = numel(PortIDs);
b = true(size(PortIDs));  %Default, assume all ports are valid
for ct=1:nPorts
   hPort = PortIDs(ct);
   try 
      blk = find_system(sprintf('%s/%s',this.getName,hPort.getBlock));
   catch
      %Block defined by port could not be found
      b(ct) = false;
   end
   if b(ct)
      hBlk = get_param(blk{1},'Object');
      if hPort.getPortNumber > numel(hBlk.PortHandles.Outport)  
         %Block port number defined by port does not exist
         b(ct) = false;
      end
   end
end
