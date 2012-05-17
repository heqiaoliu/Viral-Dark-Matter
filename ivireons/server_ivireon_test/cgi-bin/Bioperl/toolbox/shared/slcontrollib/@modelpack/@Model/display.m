function display(this)
% DISPLAY Show object properties in a formatted form

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2005/11/15 01:37:56 $

if length(this) > 1
  builtin('disp', this)
  return
end

fprintf( '           Model: %s \n', this.getName );

fprintf( '      No. inputs: %d \n', length(this.getInputs) );
fprintf( '     No. outputs: %d \n', length(this.getOutputs) );
fprintf( '  No. parameters: %d \n', length(this.getParameters) );
fprintf( '      No. states: %d \n', length(this.getStates) );
