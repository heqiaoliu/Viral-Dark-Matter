function removeSource(this,PortID) 
% REMOVESOURCE  Method to remove requirement source(s)
%
 
% Author(s): A. Stothert 22-Jun-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:26 $

for ct=1:numel(this)
   idx = false(size(this(ct).Source));
   for ctS = 1:numel(this(ct).Source)
      if isSame(this(ct).Source(ctS),PortID)
         idx(ctS) = true;
      end
   end
   if any(idx)
      this(ct).Source(idx) = [];
      ed = handle.EventData(this(ct),'sourceChanged');
      this(ct).send('sourceChanged',ed);
   end
end
