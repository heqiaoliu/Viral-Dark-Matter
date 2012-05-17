function t = cleanEvents(t,rtol)
% Takes a sorted time vector T and equates successive 
% entries that differ by less than RTOL in relative terms.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:13 $
lt = length(t);
while true
   dt = diff(t,1,1);
   idx = find(dt>0 & dt<rtol*t(2:lt,:));
   if isempty(idx)
      break
   else
      t(idx) = t(idx+1);
   end
end
