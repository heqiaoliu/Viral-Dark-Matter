function [Value,ValStr] = pvget(tsc,Property)
%PVGET  Get values of tscollection properties.
%
%   VALUES = PVGET(TSC) returns the property values in a cell array VALUES.
%
%   VALUE = PVGET(TSC,PROPERTY) returns the value of PROPERTY.
%
%   See also TSCOLLECTION\GET.

%   Author(s): Rong Chen, James Owen
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2006/06/27 23:07:25 $


if nargin==2,
   % Value of single property: VALUE = PVGET(TS,PROPERTY)
   Value = tsc.(Property);
else
   % Return all public property values
   PropNames = fieldnames(tsc);
   Value = cell(length(PropNames),1);
   for k=1:length(PropNames)
       Value{k} = get(tsc,PropNames{k});
   end
   if nargout==2,
      ValStr = pvformat(tsc,Value);
   end
end
