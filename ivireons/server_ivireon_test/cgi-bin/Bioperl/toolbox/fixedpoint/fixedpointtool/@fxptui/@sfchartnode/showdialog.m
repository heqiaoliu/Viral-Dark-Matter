function showdialog(h)
%SHOWDIALOG   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:35 $


daobj = h.daobject;
if(~isempty(daobj))
  daobj.getHierarchicalChildren.dialog;
end

% [EOF]
