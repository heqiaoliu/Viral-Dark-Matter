function itemValue = getItemValue(this, hEye, item)
%GETITEMVALUE Return the property value
%   OUT = GETITEMVALUE(THIS, HEYE, ITEM) return OUT, which is the value of the
%   ITEM property of the eye diagram object HEYE

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:49 $

if isempty(hEye)
    itemValue = '-';
else
    dotLocation = findstr('.', item.FieldName);
    if isempty(dotLocation)
        itemValue = get(hEye, item.FieldName);
    else
        fName = item.FieldName;
        itemValue = get(...
            get(hEye, fName(1:dotLocation-1)),...
            fName(dotLocation+1:end));
    end
end

%-------------------------------------------------------------------------------
% [EOF]
