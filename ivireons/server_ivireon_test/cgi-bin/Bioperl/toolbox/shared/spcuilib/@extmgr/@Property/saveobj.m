function s = saveobj(this)
%SAVEOBJ  Save this object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/18 02:13:44 $

s.Name   = this.Name;
s.Status = this.Status;
s.Type   = get(findprop(this, 'Value'), 'DataType');
s.Value  = this.Value;

% [EOF]
