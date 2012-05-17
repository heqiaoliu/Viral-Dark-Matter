function updatedata(h, runs)
%UPDATEDATA refreshes data

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:42 $

if(~exist('runs', 'var'))
  runs = [0 1];
end

results = h.getresults(runs);
for r = 1:numel(results)
  result = results(r);
  result.updatefigures;
end

% [EOF]
