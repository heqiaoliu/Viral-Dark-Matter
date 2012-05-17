function set(this,varargin) 
% SET method to set object properties
%
 
% Author(s): A. Stothert 17-Mar-2006
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:49 $

nSet = numel(varargin);
if rem(nSet,2)
    ctrlMsgUtils.error('Controllib:general:CompletePropertyValuePairs','ctrluis.numericaltextfield/set')
end
for ct = 1:(nSet/2)
   setProp(this,varargin{2*ct-1},varargin{2*ct});
end
