function dfcbkclear
%DFCBKCLEAR Callback for Clear button

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:37 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Clear all saved fits from the plot and notify fits manager
fitdb = getfitdb;
fit = down(fitdb);
while(~isempty(fit))
   fit.plot = 0;
   fit = right(fit);
end

% Clear all datasets from the plot and notify data sets manager
dsdb = getdsdb;
ds = down(dsdb);
while(~isempty(ds))
   ds.plot = 0;
   ds = right(ds);
end

dfupdatexlim;
dfupdateallplots;
dfupdateylim;
