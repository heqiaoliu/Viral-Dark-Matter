function setstate(this, state)
%SETSTATE Sets the state of a winspecs object
%   This function is required because of the 'Window' property :
%   we need to copy the window object (and not just copy the handle).

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2007/12/14 15:20:17 $

error(nargchk(1,2,nargin,'struct'));

if isrendered(this)
    l = get(this, 'WhenRenderedListeners');
    l = find(l, 'sourceobject', findprop(this, 'isModified'));
else
    l = [];
end

set(l, 'Enabled', 'Off');

if isempty(state),
    set(this, 'Window', [], ...
        'MATLABExpression', '', ...
        'Name', '', ...
        'Data', [], ...
        'Parameters', []);
else

    % Keep that order
    set(this, 'Parameters', state.Parameters);

    if ~isempty(state.Window),
        % Copy of the window object is needed to have two different objects
        set(this, 'Window', copyobj(state.Window));
    end
    % Keep that order
    set(this, ...
        'MATLABExpression', state.MATLABExpression, ...
        'Name', state.Name, ...
        'Data', state.Data, ...
        'Length', state.Length, ...
        'SamplingFlag', state.SamplingFlag);

end

set(l, 'Enabled', 'On');

set(this, 'isModified', false);

% [EOF]
