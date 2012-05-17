function out = pStruct(obj)
; %#ok Undocumented
%PSTRUCT Convert all UDD object fields to a structure
%
%  PSTRUCT(OBJ)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:39:40 $ 

hThisClass = classhandle(obj);
props = hThisClass.Properties;
numProps = length(props);
fields = cell(numProps, 1);
values = cell(numProps, 1);
for i = 1:numProps
    fields{i} = props(i).Name;
    values{i} = obj.(props(i).Name);
end
out = cell2struct(values, fields);