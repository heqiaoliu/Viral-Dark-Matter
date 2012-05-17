function boo = isvisible(this)
%ISVISIBLE  Determines actual visibility of dataview object(s).

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:03 $

% Vectorized
boo = strcmp(this.Visible,'on') & this(1).Parent.isvisible;
