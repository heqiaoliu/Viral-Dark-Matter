function clear_parent_system_selection(hSystem)
%
% Clear the parent system selection
%

%	Copyright 1995-2005 The MathWorks, Inc.
%	$Revision: 1.1.6.3 $  $Date: 2007/02/22 00:23:17 $

parentSystem = get_param(hSystem, 'parent');
h = find_system(parentSystem, 'FindAll', 'on', 'Selected', 'on');

% Set each element of the vector to unselected
for i=1:length(h)
    set_param(h(i), 'Selected', 'off');
end




