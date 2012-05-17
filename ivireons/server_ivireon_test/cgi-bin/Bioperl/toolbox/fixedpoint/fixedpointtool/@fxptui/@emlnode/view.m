function view(h)
%OPEN function

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/08/08 12:52:49 $
    
daobj = h.daobject;
if ~isempty(daobj)
    hch = daobj.getHierarchicalChildren;
    hch.view;
end

% [EOF]


    
