classdef IntEnumType < int32 & Simulink.PrivateEnumType
%INTENUMTYPE Class definition for Simulink.IntEnumType.
%
%  This is an abstract class and cannot be directly instantiated.
%
%  To define enumerated data types for use with Simulink, create an enumerated
%  class that is a subclass of Simulink.IntEnumType as follows:
%
%    classdef MyEnumClass < Simulink.IntEnumType
%      enumeration
%        EnumName1(UnderlyingValue1)
%        EnumName2(UnderlyingValue2)
%        ...
%      end
%    end
%
%  Use the following syntax to instantiate your class:
%    MyEnumClass.EnumName1
%  OR
%    MyEnumClass(UnderlyingValue1)
%  
%  You can also implement the following static methods to define class attributes:
%  - getDescription (defined in Simulink.DataTypeInterface)
%  - getHeaderFile  (defined in Simulink.DataTypeInterface)
%  - getDefaultValue
%  - addClassNameToEnumNames
%
%  For more information, see documentation on enumerated data types in Simulink.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2010/05/20 03:19:00 $

  
  methods (Static)
    % function retVal = getDefaultValue()
    %   % GETDEFAULTVALUE  Returns the default enumerated value.
    %   %   This value must be an instance of the enumerated class.  It is
    %   %   used by Simulink when an instance of this class is needed but
    %   %   the value is not known (e.g., when initializing ground values or
    %   %   when casting an invalid numeric value to an enumerated data type).
    %   %   If this method is not defined, the first enumerated value is used.
    %
    %   retVal = ClassName.NameOfDefaultValue;
    % end
    
    function retVal = addClassNameToEnumNames()
      % ADDCLASSNAMETOENUMNAMES  Control whether class name is added as
      %   a prefix to enumeration names in the generated code.
      %   By default we do not add the prefix.
      retVal = false;
    end
  end

  
  %  ------- PROTECTED CONSTRUCTOR -------
  methods (Access = protected, Hidden)
    function hObj = IntEnumType(values)
      % INTENUMTYPE  Constructor for Simulink.IntEnumType.
          
      if (nargin == 0)
          DAStudio.error('Simulink:utility:SimulinkIntEnumTypeNoArgs');
      end
      
      columnOfValues = values(:);
      
      % Check that all values are real, finite integers.
      if ((nargin ~= 1)      || ...
          (~isnumeric(values)) || ...
          (~isreal(values))   || ...
          (~all(isfinite(columnOfValues))) || ...
          (~all(rem(columnOfValues,1)==0))  || ...
          (issparse(values)))
        DAStudio.error('Simulink:utility:EnumsMustBeRealInt');
      end

      % Check that the values fit within the representable range of int32
      if (any(columnOfValues < double(intmin)) || ...
          any(columnOfValues > double(intmax)))
        DAStudio.error('Simulink:utility:EnumsMustFitIntoInt32');
      end
      
      hObj = hObj@int32(values);
    end
  end

end
