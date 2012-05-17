function [outputs, varargout] = simulate(this, varargin)
% SIMULATE Simulates the model and returns its time response.
%
% [outputs, info] = this.simulate(timespan, inputs, options)
%
% For a model with m inputs and n outputs:
%
% TIMESPAN is one of: TFinal, [TStart TFinal], or [TStart OutputTimes TFinal].
% INPUTS   is a (mx1) cell array of TIMESERIES objects, one per model input.
% OPTIONS  is a SIMOPTIONS object.
%
% OUTPUTS  is a (nx1) cell array of TIMESERIES objects, one per model output.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:40 $

outputs = [];

nout = max(nargout,1) - 1;
if nout > 0
  varargout(1:nout) = {[]};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
