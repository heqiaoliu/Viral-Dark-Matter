function deleteview(this)
%DELETEVIEW  Deletes @view and associated g-objects.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:44 $
for ct = 1:length(this)
  % Delete graphical objects
  h = ghandles(this(ct));
  delete(h(ishandle(h)))
end

% Delete views
delete(this)
