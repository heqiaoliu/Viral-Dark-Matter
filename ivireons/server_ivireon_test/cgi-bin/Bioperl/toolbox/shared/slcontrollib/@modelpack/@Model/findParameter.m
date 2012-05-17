function parameter = findParameter(this, varargin)
% FINDPARAMETER  Returns the parameter identifier objects specified by
% their (partial) full name.
%
% +findParameter(fullname : string) : ParameterID[0..*] % All matching parameters
%
% FULLNAME is the (partial) full name of the parameter.
%
% PARAMETER is an array of matching PARAMETERID objects or EMPTY if a parameter
% cannot be found.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:08 $

parameter = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
