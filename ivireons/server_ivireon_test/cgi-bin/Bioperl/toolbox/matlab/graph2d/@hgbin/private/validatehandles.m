function B = validatehandles(B)
%VALIDATEHANDLES  prune invalid scribehandle items from a list

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2008/08/14 01:37:50 $

if ~isempty(B)
   %HGHandles = B.HGHandle;
   HGHandles = subsref(B,substruct('.','HGHandle'));
   if iscell(HGHandles)
      HGHandles = [HGHandles{:}];
   end
   B = B(find(ishghandle(HGHandles)));            
end
