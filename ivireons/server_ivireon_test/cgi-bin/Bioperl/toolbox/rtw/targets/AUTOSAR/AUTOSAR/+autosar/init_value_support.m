function initValueSupport = init_value_support(xmldoc)
%INIT_VALUE_SUPPORT checks if AUTOSAR initial values are supported

%   Copyright 2010 The MathWorks, Inc.

xsdVerEnum = arxml.getSchemaVersion( xmldoc );

if xsdVerEnum >= 2
    % 2.1 and above
    initValueSupport=true;
else
    % 2.0
    initValueSupport=false;
end


