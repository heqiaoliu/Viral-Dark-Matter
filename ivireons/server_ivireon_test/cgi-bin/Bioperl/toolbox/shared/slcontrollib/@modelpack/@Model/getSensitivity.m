function [derivs, varargout] = getSensitivity(this, varargin)
% GETSENSITIVITY Computes sensitivity derivatives of model trajectories with
% respect to parameter changes
%
% [derivs,info] = this.getSensitivity(time, inputs, configset, variables)
% [lResp, rResp, info] = this.getSensitivity(...)
%
% TIMESPAN is one of: TFinal, [TStart TFinal], or [TStart OutputTimes TFinal].
% INPUTS is a cell array of TIMESERIES objects, one per model input.
% OPTIONS is a GRADOPTIONS object.
%
% DERIVS is a cell array of TIMESERIES objects, one per parameter per model
% output.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:37 $

derivs = [];

nout = max(nargout,1) - 1;
if nout > 0
  varargout(1:nout) = {[]};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
