function schema

% Copyright 2003-2005 The MathWorks, Inc.

schema.package('codegen');

% Add enumeration type to describe the datatype
% This is needed for datatypes that can be expressed several
% different ways in m-code (i.e. char array). This enumeration
% allows the client object to specify how to express the code
if (isempty(findtype('DataTypeDescriptor')))
  schema.EnumType('DataTypeDescriptor',{'Auto','CharNoNewLine'});
end