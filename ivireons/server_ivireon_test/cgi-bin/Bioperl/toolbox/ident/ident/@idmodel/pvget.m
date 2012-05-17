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

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2009/07/09 20:52:06 $

if nargin==2,
    % Value of single property: VALUE = PVGET(SYS,PROPERTY)
    try
        Value = sys.(Property);
    catch
        try
            Value = sys.Algorithm.(Property);
        catch
            Value = sys.EstimationInfo.(Property);
        end
    end
else
    % Return all public property values
    % RE: Private properties always come last in IDMODEL PropValues
    IDMPropNames  = pnames(sys);
    IDMPropValues = struct2cell(sys);
    Value = IDMPropValues(1:length(IDMPropNames));
end
