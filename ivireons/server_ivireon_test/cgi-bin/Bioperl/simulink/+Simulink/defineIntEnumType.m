% SIMULINK.DEFINEINTENUMTYPE  Define enumerated data types for use with Simulink.
%   The resulting MATLAB class is a subclass of Simulink.IntEnumType.
%
% Basic Syntax (required arguments):
% ----------------------------------
% Simulink.DefineIntEnumType(CLASSNAME, ENUMNAMES, NUMVALUES)
%
%   where:
%   - CLASSNAME: Name of enumerated type
%   - ENUMNAMES: Cell array of strings (enumeration names)
%   - NUMVALUES: Vector of underlying numeric values
%
% Optional Arguments (property-value pairs):
% ------------------------------------------
% Simulink.DefineIntEnumType(CLASSNAME, ENUMNAMES, NUMVALUES, PROPERTY, VALUE, ...)
%   
%   where PROPERTY is one of the following strings:
%   - Description:  VALUE is string describing enumerated type.
%   - DefaultValue: VALUE is name of the default enumeration (member of ENUMNAMES).
%   - HeaderFile:   VALUE is name of header file to import type in generated code.
%   - AddClassNameToEnumNames: VALUE is logical value to control whether class name
%                   is added as prefix to enumeration names in generated code.
%
% See also: Simulink.IntEnumType

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/05/20 03:19:02 $
