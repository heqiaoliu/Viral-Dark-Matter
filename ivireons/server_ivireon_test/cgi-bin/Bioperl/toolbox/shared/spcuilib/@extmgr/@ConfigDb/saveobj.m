function s = saveobj(this)
%SAVEOBJ  Save this object.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/08/24 15:06:14 $

s.Name        = this.Name;
s.Description = this.Description;
s.Version     = 1;
s.AllowConfigEnableChangedEvent = this.AllowConfigEnableChangedEvent;

s.Children = this.allChild;

% [EOF]
