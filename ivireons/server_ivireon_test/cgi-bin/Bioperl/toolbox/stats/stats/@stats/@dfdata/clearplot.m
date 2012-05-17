function clearplot(ds)
%CLEARPLOT Clear current plot data

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:40 $
%   Copyright 2003-2008 The MathWorks, Inc.

ds.plotx = [];
ds.ploty = [];
if ~isempty(ds.line) && ishghandle(ds.line)
   delete(ds.line);
end
