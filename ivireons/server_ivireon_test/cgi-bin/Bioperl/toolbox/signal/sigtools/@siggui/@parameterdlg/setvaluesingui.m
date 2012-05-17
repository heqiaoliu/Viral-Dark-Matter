function setvaluesingui(this, indx, value)
%SETVALUESINGUI   Set the values in the gui

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:19:07 $

error(nargchk(3,3,nargin,'struct'));

if isa(indx, 'sigdatatypes.parameter'),
    indx = get(indx, 'Tag');
elseif ischar(indx),
    indx  = find(strcmpi(get(this.Parameters, 'Tag'), indx));
    value = {value};
elseif iscell(indx),
    for jndx = 1:length(indx),
        indx{jndx} = find(strcmpi(get(this.Parameters, 'Tag'), indx{jndx}));
    end
    indx = [indx{:}];
end

for jndx = 1:length(indx)
    lclsetvalue(this, indx(jndx), value{jndx});
end

% ------------------------------------------------------------------
function lclsetvalue(this, indx, value)

hPrm = get(this, 'Parameters');

if isrendered(this),
    h    = get(this, 'Handles');

    if isempty(hPrm),
        value = [];
        return;
    end

    % If validvalues for the parameter is a cell, then the info must be in
    % a popup
    vv = hPrm(indx).ValidValues;
    if isnumeric(vv),
        set(h.controls(indx).edit, 'String', value);
    elseif iscell(vv),
        if isnumeric(value),
            set(h.controls(indx).specpopup, 'Value', value);
        else
            set(h.controls(indx).specpopup, 'Value', find(strcmpi(vv, value)));
        end
    elseif ischar(vv) & strcmpi(vv, 'on/off')
        if strcmpi(value, 'off'),
            set(h.controls(indx).checkbox, 'Value', 0);
        else
            set(h.controls(indx).checkbox, 'Value', 1);
        end
    else
        set(h.controls(indx).edit, 'String', value);
    end
else
    return;
end

% [EOF]
