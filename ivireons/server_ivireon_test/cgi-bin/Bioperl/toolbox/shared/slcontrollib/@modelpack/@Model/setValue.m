function setValue(this, varargin)
% SETVALUE Sets the value of the specified ports, parameters and/or initial
% states in the model.
%
% this.setValue(hVal)
% this.setValue(hId, value)
% this.setValue(hId, {values})
% this.setValue('variablename', value)
%
% HVAL is an array of VARIABLEVALUE objects.
% HID  is an array of PARAMETERID or STATEID objects.
% VARIABLENAME is the relative or absolute full name of the
% port/parameter/state.  Partial name matching is also supported.
%
% The method errors out if the port/parameter/state(s) cannot be found, if
% the full name is ambiguous, or if the value size or type does not match
% that of the variable.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:19 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
