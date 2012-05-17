function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public LTI properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   Author(s): P. Gahinet, 7-8-97
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 17:31:05 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   Value = sys.(Property);
   
else
   % Return all public property values
   % RE: Private properties always come last in LTIPropValues
   PropNames = pnames(sys);
   PropValues = struct2cell(sys);
   Value = PropValues(1:length(PropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end
