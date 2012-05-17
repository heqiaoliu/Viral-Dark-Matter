function hLin = addLinearizationIO(this, varargin)
% ADDLINEARIZATIONIO Adds new linearization I/O ports to the model.
%
% hLin = this.addLinearizationIO(name, [type], [openloop])
% hLin = this.addLinearizationIO(hId)
%
% HID  is an array of LINEARIZATIONIO objects to be added as lin. ports.
% NAME is the relative or absolute full name of the lin. I/O to be added.
% HLIN is an array of LINEARIZATIONIO objects added as lin. ports.
%
% The method errors out if the linearization I/O port(s) cannot be added.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:53 $

hLin = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
