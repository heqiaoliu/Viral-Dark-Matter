function minmax = xlim(ds)
%XLIM Return the X plot limits for this dataset

% $Revision: 1.1.6.1 $    $Date: 2010/03/16 00:21:52 $
% Copyright 2003-2004 The MathWorks, Inc.

if isempty(ds.xlim)
   minmax = ds.datalim;   % use data limits if nothing else available
else
   minmax = ds.xlim;
end