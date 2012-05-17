function values = getvaluesfromgui(this, indx)
%GETVALUESFROMGUI Gets the parameter values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2004/04/13 00:24:46 $

if nargin == 1,
    for i = 1:length(this.Parameters)
        values{i} = getvalue(this, i);
    end
else
    if isa(indx, 'sigdatatypes.parameter'),
        indx = get(indx, 'Tag');
        if iscell(indx)
            for jndx = 1:length(indx)
                values{jndx} = getvalue(this, find(strcmpi(get(this.Parameters, 'Tag'), indx{jndx})));
            end
            return;
        end
    end
    if ischar(indx),
        indx = find(strcmpi(get(this.Parameters, 'Tag'), indx));
    end
    values = getvalue(this, indx);
end


% ------------------------------------------------------------------
function value = getvalue(this, indx)

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
        value = evaluatevars(get(h.controls(indx).edit,'String'));
    elseif iscell(vv),
        value = get(h.controls(indx).specpopup, 'Value');
    elseif ischar(vv) & strcmpi(vv, 'on/off')
        if get(h.controls(indx).checkbox, 'Value')
            value = 'on';
        else
            value = 'off';
        end
    else
        value = get(h.controls(indx).edit, 'String');
        if ~isvalid(hPrm(indx), value),
            value = evaluatevars(value);
        end
    end
else
    value = get(hPrm(indx), 'Value');
end

% [EOF]
