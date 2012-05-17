function hVal = getValue(this, varargin)
% GETVALUE Returns value objects for the specified ports, parameters and/or
% initial states in the model.
%
% hVal = this.getValue(hId)
% hVal = this.getValue('variablename')
%
% HID is an array of VARIABLEID objects.
% VARIABLENAME is the relative or absolute full name of the
% port/parameter/state.  Partial name matching is also supported.
% HVAL is an array of VARIABLEVALUE objects.
%
% The method returns an empty handle for the port/parameter/state(s) that
% cannot be found or if the full name is ambiguous.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:17 $

hVal = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
