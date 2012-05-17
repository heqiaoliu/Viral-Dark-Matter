function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:41:47 $

if strcmp(Event,'postlim')
   if strcmp(cv.AxesGrid.YNormalization,'on')
       return
   else
       draw(cv,cd,NormalRefresh)
   end
end
