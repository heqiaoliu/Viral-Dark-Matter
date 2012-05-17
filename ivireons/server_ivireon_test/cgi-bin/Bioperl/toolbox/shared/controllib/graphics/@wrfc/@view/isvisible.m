function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @view object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:46 $
boo = strcmp(get(this,'Visible'),'on');
if ~isempty(this(1).Parent)
   boo = boo & isvisible(this(1).Parent);
end