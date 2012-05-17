function schema
% SCHEMA Package definition

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2006/09/30 00:22:58 $

schema.package('modelpack');

% ----------------------------------------------------------------------------
% Define enumerated string types

% Model I/O type for @PortID and @LinearizationIO objects
if isempty( findtype('Model_IOType') )
  schema.EnumType( 'Model_IOType', {'Input','Output','InOut','OutIn','None'} );
end

% Gradient type for Jacobian (sensitivity) computations.
if isempty( findtype('Model_GradientType') )
  schema.EnumType( 'Model_GradientType', {'basic', 'refined'} );
end
