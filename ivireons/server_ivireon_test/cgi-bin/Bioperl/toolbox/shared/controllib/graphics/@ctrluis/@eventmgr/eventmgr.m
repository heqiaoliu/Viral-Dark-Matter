function h = eventmgr(Container)
% Returns instance of @eventmgr class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:18 $

h = ctrluis.eventmgr;
if nargin
    h.SelectedContainer = Container;
end
