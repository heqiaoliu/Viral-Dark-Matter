function hRegister = findRegister(this, type, name)
%FINDREGISTER Find extension registration in database.
%  FINDREGISTER(H,'Type','Name') returns specified registration in database.
%  If not found, empty is returned.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:59 $

% Parse the inputs.
if nargin == 2
    if ischar(type)
        [type, name] = strtok(type, ':');
        if isempty(name)
            hRegister = findChild(this, 'Type', type);
            return;
        else
            name(1) = [];
        end
    else
        name = get(type, 'Name');
        type = get(type, 'Type');
    end
end

% Search the database.
hRegister = findChild(this, 'Type', type, 'Name', name);

% [EOF]
