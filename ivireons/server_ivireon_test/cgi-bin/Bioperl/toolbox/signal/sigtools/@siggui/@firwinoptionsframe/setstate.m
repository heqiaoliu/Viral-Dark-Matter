function setstate(this, s)
%SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $ $Date: 2009/01/20 15:36:08 $

error(nargchk(2,2,nargin,'struct'));

switch s.Version
    case 1
        s.Parameter = s.ParamCell;
        s = rmfield(s, 'ParamCell');
        set(this, 'privWindow', feval(['sigwin.' s.Window]));
        s = rmfield(s, 'Window');
    case 2
        if strcmpi(s.Window, 'user defined')
            s.Parameter2 = s.Parameter;
            s.Parameter  = s.FunctionName;
        end
        s = rmfield(s, 'FunctionName');
    case 3
        % Currently defined properties match this case.  There is no
        % transformation needed, we can set the structure into the object.
end

siggui_setstate(this, s);

% [EOF]
