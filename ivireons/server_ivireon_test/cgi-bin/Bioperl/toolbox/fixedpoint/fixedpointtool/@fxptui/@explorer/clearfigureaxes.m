function clearfigureaxes(h)
%CLEARFIGUREAXES

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:31 $

[dataset, run] = h.getdataset;
results = h.getresults(run);
for r = 1:numel(results)
	result = results(r);
  result.clearfigureaxes;
end


% [EOF]
