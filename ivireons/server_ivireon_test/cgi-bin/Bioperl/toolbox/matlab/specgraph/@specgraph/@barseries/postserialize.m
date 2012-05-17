function postserialize(this,olddata) %#ok
%POSTSERIALIZE Restore a bar plot for serialization.
  
%   Copyright 2007 The MathWorks, Inc.

% Remove bar peer appdata:

if isappdata(double(this),'SerializedBarPeers')
    rmappdata(double(this),'SerializedBarPeers');
end