function b = hasproposedfl(h,run)
%HASPROPOSEDFL(RUN)   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:42 $

b =false;
results = h.getresults(run);
if(isempty(results)); return; end
for r = 1:numel(results)
	if(results(r).hasproposedfl)
		b = true;
		break;
	end
end

% [EOF]
