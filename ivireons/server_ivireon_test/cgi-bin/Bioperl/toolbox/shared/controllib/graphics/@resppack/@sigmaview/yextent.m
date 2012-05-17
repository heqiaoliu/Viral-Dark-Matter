function hy = yextent(this,VisFilter)
%  YEXTENT  Gathers all handles contributing to Y limits.

%  Author: Pascal Gahinet
%  Revised: Kamesh Subbarao, 10-16-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:23 $

hy = this.Curves;
hy(~VisFilter) = handle(-1);  % discard invisible curves
