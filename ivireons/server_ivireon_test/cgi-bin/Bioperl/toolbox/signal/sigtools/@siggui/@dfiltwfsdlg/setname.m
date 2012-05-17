function setname(hObj, name, indx)
%SETNAME Set the backup name at the specified index

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2007/12/14 15:18:21 $

error(nargchk(2,3,nargin,'struct'));

if nargin < 3,
    indx = get(hObj, 'Value');
end

names = get(hObj, 'BackupNames');

if indx > length(names),
    error(generatemsgid('InternalError'),'Internal error: Index is greater than the number of filters.');
end

names{indx} = name;

set(hObj, 'BackupNames', names);

% [EOF] $File: $
