function this = PropertyDb(varargin)
%PROPERTYDB Database of extension properties.
%  PROPERTYDB constructs a new configuration object containing property
%  names and values for a single extension (plug-in).
%
%  PROPERTYDB(P1,P2,...) automatically adds Property objects P1,P2,... to
%  the database.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/04/09 19:04:28 $

this = extmgr.PropertyDb;

this.ChildListeners = [ ...
    handle.listener(this, 'ObjectChildAdded',   @(hSrc, ed) childrenChanged(this)); ...
    handle.listener(this, 'ObjectChildRemoved', @(hSrc, ed) childrenChanged(this))];

% Prop objects P1,P2,P3... specified
add(this,varargin{:});

% -------------------------------------------------------------------------
function childrenChanged(this)

hAll = allChild(this);
if isempty(hAll);
    hListen = [];
else
    
    % Add a listener for each property child.
    for indx = 1:length(hAll)
        hListen(indx) = handle.listener(hAll(indx), ...
            hAll(indx).findprop('Value'), 'PropertyPostSet', ...
            @(hSrc, ed) send(this, 'PropertyChanged', ed)); %#ok
    end
end

this.PropertyListeners = hListen;

% [EOF]
