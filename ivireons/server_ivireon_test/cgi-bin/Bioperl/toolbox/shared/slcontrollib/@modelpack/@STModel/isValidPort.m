function b = isValidPort(this,PortIDs) 
% ISVALIDPORT check that ports are valid for this model
%
% b = this.isValidPort(PortIDs)
%
% Inputs:
%   PortIDs - a vector of modepack.STPortID objects
% Outputs:
%   b - a vector of logicals indicating whether the passed ports are valid
%       for this model
 
% Author(s): A. Stothert 11-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:57:01 $

if ~isa(PortIDs,'modelpack.STPortID')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','PortIDs','modelpack.SLPortID')
end

%As ports cannot be added or removed via the modelPI need to check that the
%ports are the same as any in the model.
allPorts = [this.getOutputs; this.getInputs; this.getLinearizationIOs];
nAll = numel(allPorts);
b = false(size(PortIDs));
for ct=1:numel(PortIDs)
   ctAll = 1;
   while ~b(ct) && ctAll <= nAll
      if PortIDs(ct).isSame(allPorts(ctAll))
         b(ct) = true;
      else
         ctAll = ctAll + 1;
      end
   end
end

