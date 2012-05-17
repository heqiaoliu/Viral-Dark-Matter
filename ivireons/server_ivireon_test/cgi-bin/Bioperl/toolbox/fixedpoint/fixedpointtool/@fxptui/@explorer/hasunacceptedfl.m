function b = hasunacceptedfl(h,run)
%HASPROPOSEDFL(RUN)   

%   Author(s): V. Srinivasan
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:16 $

b = false;
results = h.getresults(run);
if(isempty(results)); return; end
for r = 1:numel(results)
    if (results(r).hasproposedfl && results(r).Accept)
       	b = true;
        break;
    end
end
