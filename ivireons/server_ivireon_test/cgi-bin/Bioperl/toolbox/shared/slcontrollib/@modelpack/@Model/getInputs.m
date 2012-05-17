function inputs = getInputs(this, varargin)
% GETINPUTS Returns all or specified input port information.
%
% +getInputs() : PortID[0..*]                      % All inputs
% +getInputs(indices : int[1..n]) : PortID[1..n]   % Selected inputs

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/09/30 00:23:11 $

inputs = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
