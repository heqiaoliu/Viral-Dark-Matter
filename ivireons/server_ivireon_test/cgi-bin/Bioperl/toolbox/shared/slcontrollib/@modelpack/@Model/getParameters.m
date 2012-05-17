function parameters = getParameters(this, varargin)
% GETPARAMETERS Returns all or specified parameter information.
%
% +getParameters() : ParameterID[0..*]                     % All parameters
% +getParameters(indices : int[1..n]) : ParameterID[1..n]  % Selected parameters

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/09/30 00:23:14 $

parameters = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
