function idx = util_enum2val(type,enum)
%UTIL_ENUM2VAL Convert an enumerated string to its numerical equivalent.
%
% -- Usage ---
%
%   idx = util_enum2val(type, enum)
%
% -- Arguments ---
%
%   type    -   A string indicating the enumeration class to look up
%   enum    -   A string representing the enumeration value to lookup
%
% -- Returns   ---
%
%   An integer representing the numerical equivalent of the enumeration
%   string.
%
% -- Example ---
%
%   v = util_enum2val('color','red');
%

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
%   $Date: 2009/05/18 21:16:05 $

typeClass = findtype(type);
if isempty(typeClass)
    TargetCommon.ProductInfo.error('resourceConfiguration', ...
        'InvalidUDDType', ...
        type);
end

idx = find(strcmp(enum, typeClass.Strings));

if isempty(idx)
    TargetCommon.ProductInfo.error('resourceConfiguration', ...
        'InvalidEnumerationString',...
        enum, type);
end

idx = int32(typeClass.Values(idx));


