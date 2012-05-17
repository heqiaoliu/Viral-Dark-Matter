function addSource(this,PortID,Type)
% ADDSOURCE  Method to add a requirement source
%

% Author(s): A. Stothert 22-Jun-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:11 $

for ct = 1:numel(this)
   src = this(ct).Source;
   same = false; ctS = 1;
   while ~same && ctS <= numel(src)
      if isSame(src(ctS),PortID)
         same = true;
      else
         ctS = ctS + 1;
      end
   end
   if ~same
      this(ct).Source = [this(ct).Source; PortID];
      ed = handle.EventData(this(ct),'sourceChanged');
      this(ct).send('sourceChanged',ed)
   end
end
