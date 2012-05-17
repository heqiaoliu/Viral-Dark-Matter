function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @plot object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:30 $
boo = strcmp(this.Visible,'on') && strcmp(this.AxesGrid.Parent.Visible,'on');