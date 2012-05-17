function [hc, sep] = addcsmenu(hlbl)
%ADDCSMENU Setup a contextmenu on an HG object
%   ADDCSMENU(HLBL) Setup a contextmenu on an HG object.  This function
%   returns the handle to the contextmenu.  If a context menu already exists for
%   the object, it will not be overwritten.  The second output is the separator
%   state, which will be 'On' if a context menu is present.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2007/12/14 15:15:24 $

error(nargchk(1,1,nargin,'struct'));

hc  = get(hlbl, 'UIContextmenu');

if iscell(hc),
    hc = [hc{:}];
end

if length(hc) > 1,
    error(generatemsgid('InvalidDimensions'),'Cannot create context-menu on multiple objects.');
end
sep = 'On';

if isempty(hc),
    hFig = ancestor(hlbl, 'figure');
    
    % Create a context menu on the Label
    hc = uicontextmenu('Parent', hFig);
    set(hlbl, 'UIContextMenu', hc);
    sep = 'Off';
end

% If there are no children make no separator
if ~length(allchild(hc)), sep = 'Off'; end

% [EOF]
