function enabdynprop(h,propname,enabstate)
%ENABDYNPROP Enable/disable dynamic properties.
%   ENABDYNPROP(H, PROP, ENAB) Set the enable state of the dynamic property
%   PROP in the object H to ENAB.
%
%   We enable/disable the set/get accessflags of dynamic properties
%   in order to enable/disable the properties.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2008/08/22 20:32:55 $
if ~iscell(propname)
    propname = {propname};
end

for i=1:length(propname)
    p = findprop(h,propname{i});
    if ~strcmpi(propname{i},get(p,'Name')),
        error(generatemsgid('NotSupported'),'Property not found.');
    end
    p.AccessFlags.PublicGet = enabstate;
    p.AccessFlags.PublicSet = enabstate;
end
% [EOF]
