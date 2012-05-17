function varargout = enumconst_cb(action, dtStr, enumValue)
% ENUMCONST_CB Callback for enumerated constant block.
%
%   This function checks the correctness and consistency of the mask parameters:
%   - Checks that dtStr is of the form 'Enum: <class name>' and checks that the
%     class name is a valid enumerated data type for use with Simulink.
%
%   - For MaskInit: checks that value is an instance of the enumerated class.
%   - For GetClassName: returns the class name to the caller.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 18:26:37 $

% Check number of input/output arguments
switch action
case 'MaskInit'
  assert(nargin  == 3, 'Expected 3 input arguments.');
  assert(nargout == 0, 'Expected 0 output arguments.');
case 'GetClassName'
  assert(nargin  == 2, 'Expected 2 input arguments.');
  assert(nargout == 1, 'Expected 1 output argument.');
otherwise
  assert(false, 'Unexpected action "%s".', action);
end

% Extract class name from data type string & check its validity
className = l_GetClassName(dtStr);

switch action
case 'MaskInit'
  % Check that value provided is an instance of the specified class
  if ~isa(enumValue, className)
    DAStudio.error('Simulink:blocks:EnumConstInvalidEnumValue', className);
  end
case 'GetClassName'
  % Return class name to caller
  varargout{1} = className;
end

%==============================================================================
% SUBFUNCTIONS:
%==============================================================================
function className = l_GetClassName(dtStr)

  className = strtrim(dtStr);
  if isempty(className)
    DAStudio.error('Simulink:blocks:EnumConstEmptyDataType');
  end
    
  % Remove 'Enum:' from data type string
  if ((length(className) >= 5) && ...
      (isequal(className(1:5), 'Enum:')))
    className(1:5) = '';
  else
    % Data type string did not start with 'Enum:'.
    % Error out for now to enforce consistent use of this syntax.
    DAStudio.error('Simulink:blocks:EnumConstInvalidSyntaxForDataType');
  end
    
  className = strtrim(className);
  if isempty(className)
    DAStudio.error('Simulink:blocks:EnumConstEmptyDataType');
  end
    
  if (isvarname(className) && ...
      ~isempty(Simulink.getMetaClassIfValidEnumDataType(className)))
    % Valid enumerated data type ==> keep going
  else
    DAStudio.error('Simulink:blocks:EnumConstInvalidDataType', dtStr);
  end

% EOF
