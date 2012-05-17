function Value = pvget(sys,Property)
%PVGET  Get values of public IDMODEL properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

 %   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/06/27 22:39:45 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   Value = sys.(Property);
else
   IDMPropNames  = pnames(sys);
   IDMPropValues = struct2cell(sys);
   Value = IDMPropValues(1:length(IDMPropNames));
end
