function hOut = addOutput(this, varargin)
% ADDOUTPUT Adds new output ports to the model.
%
% hOut = this.addOutput(name)
% hOut = this.addOutput(hId)
%
% HID  is an array of PORTID objects to be added as model outputs.
% NAME is the relative or absolute full name of the output to be added.
% HOUT is an array of PORTID objects added as model outputs.
%
% The method errors out if the port(s) cannot be added.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:54 $

hOut = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
