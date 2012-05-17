function [harnessHandle, neededVars] = protect(input, varargin)
%SIMULINK.MODELREFERENCE.PROTECT creates a Protected Model
%
% Simulink.ModelReference.protect(name) creates a Protected Model.  The argument
% 'name' is either the name of the model to be protected or the path name of a
% Model block that references the model to be protected.  The call puts the
% Protected Model in the current working directory, and does not create a
% harness model.
%
% harnessHandle = Simulink.ModelReference.protect(name, 'Param1', Val1, ...)
% allows you to specify optional parameter name/value pairs.  Parameter names
% and values are:
%
%    'Path' -- Path name specifying the directory where the Protected Model will
%    be created.  If not specified, 'Path' defaults to the current working
%    directory.
%
%    'Harness' -- Boolean indicating whether or not a harness model will be
%    created.  If not specified, 'Harness' defaults to false.
%
% Outputs:
%
%    harnessHandle -- If 'Harness' is true, the value is the handle of the
%    harness model.  If 'Harness' is false or omitted, the value is 0.
%
%    neededVars -- A cell array that contains the names of base workspace
%    variables that will be needed by the model being protected.  The cell 
%    array may also include the names of some variables that will not be 
%    needed by the model being protected.

    
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

    [harnessHandle, neededVars] = protect_private(input, varargin{:});
end % protect
