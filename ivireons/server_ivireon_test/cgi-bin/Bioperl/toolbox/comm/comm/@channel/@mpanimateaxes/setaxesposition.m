function setaxesposition(h, axPos);
%SETAXESPOSITION  Set axis position for multipath animation axes object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/12 23:12:25 $

% Get figure window handle.
fig = h.FigureHandle;
ax = h.AxesHandle;

% Set or get axes position.
if nargin==1
    axPos = get(ax, 'position');
else
    set(ax, 'position', axPos);
end

drawnow expose
