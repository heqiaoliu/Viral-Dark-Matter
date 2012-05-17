function Th = getCriticalPoints(this)
% Computes simulation horizon and time points needed for proper 
% requirement evaluation.
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:19 $

Th = this.Data.getData('xdata');
Th = Th(:);
%Adjust start and end times based on open-end settings
OpenEnd = this.Data.getData('openend');
if OpenEnd(1)
   %First segment extends to -inf
   Th = [-inf; Th];
end
if OpenEnd(2)
   %Last segment extends to +inf
   Th = [Th; inf];
end
