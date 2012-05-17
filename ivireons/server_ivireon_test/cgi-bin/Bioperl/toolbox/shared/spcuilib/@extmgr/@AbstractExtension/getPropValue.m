function propValue = getPropValue(this, propName)
%GETPROPVALUE Get the propValue.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:28:52 $

hProp = findProp(this, propName);
if isempty(hProp)
    error('Spcuilib:extmgr:PropertyNotFound', 'Could not find a property named ''%s''.', propName);
end
propValue = hProp.Value;

% [EOF]
