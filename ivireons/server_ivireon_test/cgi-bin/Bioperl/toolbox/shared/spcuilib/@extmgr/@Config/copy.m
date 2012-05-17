function hCopy = copy(this, copyChildren)
%COPY     Copy this object

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/03 21:37:18 $

hCopy = extmgr.Config;
hCopy.Type = this.Type;
hCopy.Name = this.Name;
hCopy.Enable = this.Enable;

if nargin > 1 && strcmpi(copyChildren, 'children')
    newProps = copy(this.PropertyDb, 'children');
else
    newProps = this.PropertyDb;
end
hCopy.PropertyDb = newProps;

% [EOF]
