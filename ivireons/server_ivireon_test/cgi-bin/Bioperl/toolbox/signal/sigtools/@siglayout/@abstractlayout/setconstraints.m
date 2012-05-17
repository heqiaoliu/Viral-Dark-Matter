function setconstraints(this, varargin)
%SETCONSTRAINTS   Set the constraints for the specified component.
%   SETCONSTRAINTS(HLAYOUT, LOCATION, PARAM1, VALUE1, etc.) Set the
%   constraints for the component in LOCATION.
%
%   SETCONSTRAINTS(HLAYOUT, LOCATION, 'default') when the string 'default'
%   is passed to SETCONSTRAINTS the stored constraints are reset to their
%   default values.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:20:43 $

n    = nfactors(this);

error(nargchk(2+n, inf, nargin,'struct'));

% Get the component from the subclass.
hComponent = getcomponent(this, varargin{1:n});

% Remove the "location information"
varargin(1:n) = [];

% Get the old constraints.
ctag           = getconstraintstag(this);
oldConstraints = getappdata(hComponent, ctag);

if strcmpi(varargin{1}, 'default')
    
    % If the pv pairs is just 'default' remove all constraints.
    if ~isempty(oldConstraints)
        rmappdata(hComponent, ctag);
    end
else
    
    % If there are no old constraints, create a new object.
    if isempty(oldConstraints)
        c = siglayout.constraints(varargin{:});
        setappdata(hComponent, ctag, c);
    else
        
        % If there are old constraints, just set the object with the new
        % constraints, don't throw away any old ones.
        set(oldConstraints, varargin{:});
    end
end

set(this, 'Invalid', true);

% Force a call to update.
update(this);

% [EOF]
