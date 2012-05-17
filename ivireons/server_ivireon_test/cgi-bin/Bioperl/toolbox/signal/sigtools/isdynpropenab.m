function flag = isdynpropenab(h,propname)
%ISDYNPROPENAB True if dynamic property is enabled (set/get are on).
%   ISDYNPROPENAB(H, PROP) True if the dynamic property PROP in the object
%   H is enabled, i.e. PublicGet and PublicSet are on.
    
%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/12/14 15:16:00 $

p = findprop(h,propname);

% Check if the property found was due to partial match
if ~strcmpi(propname,get(p,'Name')),
    error(generatemsgid('NotSupported'),'Property not found.');
end

flag = strcmpi(p.AccessFlags.PublicGet,'on') && ...
        strcmpi(p.AccessFlags.PublicSet,'on');

% [EOF]
