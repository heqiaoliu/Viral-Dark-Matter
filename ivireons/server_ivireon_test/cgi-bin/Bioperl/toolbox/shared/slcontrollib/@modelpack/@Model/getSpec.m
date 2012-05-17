function hSpec = getSpec(this, varargin)
% GETSPEC Returns specification objects for the specified ports, parameters,
% and/or initial states in the model.
%
% hSpec = this.getSpec(hId)
% hSpec = this.getSpec('variablename')
%
% HID is an array of VARIABLEID objects.
% VARIABLENAME is the relative or absolute full name of the
% port/parameter/state.  Partial name matching is also supported.
% HSPEC is an array of VARIABLESPEC objects.
%
% The method returns an empty handle for the port/parameter/state(s) that
% cannot be found or if the full name is ambiguous.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:15 $

hSpec = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
