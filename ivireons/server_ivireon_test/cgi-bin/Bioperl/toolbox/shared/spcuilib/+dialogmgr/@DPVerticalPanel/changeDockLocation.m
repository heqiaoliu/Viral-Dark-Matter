function changeDockLocation(dp,newLoc)
% Change location of InfoPanel.
% changeDockLocation(hParent,newLoc) changes location of the InfoPanel
% to 'right' or 'left' side.  If unspecified, location is toggled between
% the two.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:33 $

if nargin<2
    % Toggle current location value
    if strcmpi(dp.DockLocation,'left')
        newLoc = 'right';
    else
        newLoc = 'left';
    end
end
dp.DockLocation = newLoc;
resizeChildPanels(dp);
updateSplitterBarAction(dp); % change splitter arrow directions
