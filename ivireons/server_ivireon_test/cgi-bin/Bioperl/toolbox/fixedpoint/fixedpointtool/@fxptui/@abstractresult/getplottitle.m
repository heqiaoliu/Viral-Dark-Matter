function plottitle = getplottitle(h)
%GETPLOTTITLE Get the plottitle for this resulty

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:30 $

jFullName = java.lang.String(h.FxptFullName);
jDisplayName = jFullName.substring(jFullName.indexOf('/') + 1);
plottitle = char(jDisplayName);
idx = findstr(plottitle, ':');
if(~isempty(idx) && h.has1output)
  plottitle = plottitle(1:idx(end) - 2);
end

% [EOF]
