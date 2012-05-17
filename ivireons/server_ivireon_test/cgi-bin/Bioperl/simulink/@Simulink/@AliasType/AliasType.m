function h = AliasType(varargin)
% SIMULINK.ALIASTYPE  Data type object to define alias to another data type object
%
%   SIMULINK.ALIASTYPE calls the default constructor which returns an object with:
%   - BaseType:    'double'
%   - HeaderFile:  ''
%   - Description: ''
%
%   SIMULINK.ALIASTYPE(BASETYPE) creates an object with the specified BASETYPE.
%
%   You can configure the object properties after instantiation.
%
% See also: SIMULINK.DATATYPE

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 22:00:12 $

h = Simulink.AliasType(varargin{:});

% LocalWords:  BASETYPE DATATYPE
