function hConfig = findConfig(this, type, name)
%FINDCONFIG Find extension configuration in database.
%   FINDCONFIG(H,'Type','Name') returns specified configuration in
%   database. If configuration not found, no error occurs, and empty is
%   returned.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/04/09 19:03:52 $

if nargin == 2
    if ischar(type)
        [type, name] = strtok(type, ':');
        if isempty(name)
            hConfig = findChild(this, 'Type', type);
            return;
        else
            name(1) = [];
        end
    else
        name = get(type, 'Name');
        type = get(type, 'Type');
    end
end

hConfig = findChild(this, 'Type', type, 'Name', name);

% [EOF]
