function success = action(this)
%ACTION Convert the current filter and send it to the workspace

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2004/12/26 22:20:49 $

success = true;

% Get the new filter structure name for the filter object.
newfilterStr = getconstructor(this);
reffilt      = get(this,'ReferenceFilter');

% Convert filt to a new filter object with the new filter structure.
data.filter = convert(reffilt,newfilterStr);

if isprop(reffilt, 'maskinfo')
    p = schema.prop(data.filter, 'MaskInfo', 'mxArray');
    set(p, 'Visible', 'Off');
    set(data.filter, 'MaskInfo', get(reffilt, 'MaskInfo'));
end

data.mcode  = genmcode(this);

this.Filter = data.filter;

send(this, 'FilterConverted', ...
    sigdatatypes.sigeventdata(this, 'FilterConverted', data));

% [EOF]
