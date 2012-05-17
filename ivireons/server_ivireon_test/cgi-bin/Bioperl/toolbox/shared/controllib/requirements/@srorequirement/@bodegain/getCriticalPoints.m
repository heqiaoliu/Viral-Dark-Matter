function cP = getCriticalPoints(this)
% GETCRITICALPOINTS  method to compute frequency points needed for proper 
% evaluation of bodegain requirement.
%
 
% Author(s): A. Stothert 06-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:27 $

cP = this.Data.getData('xdata');
cP = cP(:);
%Adjust start and end frequencies based on open-end settings
OpenEnd = this.Data.getData('openend');
if OpenEnd(1)
   %First segment extends to -inf
   cP(1) = -inf;
end
if OpenEnd(2)
   %Last segment extends to +inf
   cP(end) = inf;
end
