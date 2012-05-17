function clearplot(hFit)
%CLEARPLOT Clear plot information from fit object

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:53 $
%   Copyright 2003-2008 The MathWorks, Inc.

hFit.x = [];
hFit.y = [];
if ~isempty(hFit.linehandle) && ishghandle(hFit.linehandle)
   delete(hFit.linehandle);
end
