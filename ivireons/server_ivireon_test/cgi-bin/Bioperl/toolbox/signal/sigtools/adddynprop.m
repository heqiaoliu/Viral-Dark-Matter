function varargout = adddynprop(h, name, datatype, setfcn, getfcn)
%ADDDYNPROP   Add a dynamic property
%   ADDDYNPROP(H, NAME, TYPE)  Add the dynamic property with NAME and
%   datatype TYPE to the object H.
%
%   ADDDYNPROP(H, NAME, TYPE, SETFCN, GETFCN)  Add the dynamic property and
%   setup PostSet and PreGet listeners with the functions SETFCN and GETFCN.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/14 15:15:25 $

error(nargchk(3,5,nargin,'struct'));

if nargin < 5
    getfcn = [];
    if nargin < 4
        setfcn = [];
    end
end

% Add the dynamic property.
hp = schema.prop(h, name, datatype);
set(hp, 'AccessFlags.Serialize', 'Off', ...
    'SetFunction', setfcn, ...
    'GetFunction', getfcn);

if nargout
    varargout = {hp};
end

% [EOF]
