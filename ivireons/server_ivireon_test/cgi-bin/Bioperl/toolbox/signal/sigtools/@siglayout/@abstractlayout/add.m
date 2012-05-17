function add(this, h, varargin)
%ADD   Add the component to the layout manager.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:42:56 $

% Get the number of factors that we need to determine location.
n = nfactors(this);

error(nargchk(2+n, inf, nargin,'struct'));

% Strip out the "location information"
locationinformation = varargin(1:n);
varargin(1:n) = [];

% Make sure there isn't already a component in the location.
hOld = getcomponent(this, locationinformation{:});
if ~isempty(hOld)
    error(generatemsgid('GUIErr'),'Cannot add a component to a location that is already occupied.');
end

h = double(h);

% If there is any left over information, it must be constraints.
if ~isempty(varargin)
    c = siglayout.constraints(varargin{:});
    setappdata(h, getconstraintstag(this), c);
end

if ~isnan(h)
    set(h, 'Parent', this.Panel);
end

% Add the control to the layout.  Only the subclasses know how to do this.
addtolayout(this, h, locationinformation{:});

% [EOF]
