function result = isEditableProperty(this, prop) %#ok<INUSD>
%  isEditableProperty
%  
%  Indicate to the Explorer that the user should not be able
%  to change diagnostic message properties.
%   
%  Copyright 2008 The MathWorks, Inc.

  % Return false, i.e., read-only, for all properties.
  result = false;

    
end