classdef DataTypeInterface
%DATATYPEINTERFACE Class definition file for Simulink.DataTypeInterface.
%
%  This is an abstract class and cannot be directly instantiated.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2008/06/20 08:49:28 $

  methods (Static = true)
    function retVal = getDescription()
      % GETDESCRIPTION  Optional string to describe the class.
      retVal = '';
    end

    function retVal = getHeaderFile()
      % GETHEADERFILE  File where type is defined for generated code.
      %   If specified, this file is #included where needed in the code.
      %   Otherwise, a typedef is written out in the generated code.
      retVal = '';
    end
 
  end

  % ------- PROTECTED CONSTRUCTOR -------
  methods (Access = protected, Hidden)
    function hObj = DataTypeInterface()
      % Intentionally empty
    end
  end
end
