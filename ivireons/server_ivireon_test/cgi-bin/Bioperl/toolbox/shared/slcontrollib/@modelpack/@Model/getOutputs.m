function outputs = getOutputs(this, varargin)
% GETOUTPUTS Returns all or specified output port information.
%
% +getOutputs() : PortID[0..*]                     % All outputs
% +getOutputs(indices : int[1..n]) : PortID[1..n]  % Selected outputs

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/09/30 00:23:13 $

outputs = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
