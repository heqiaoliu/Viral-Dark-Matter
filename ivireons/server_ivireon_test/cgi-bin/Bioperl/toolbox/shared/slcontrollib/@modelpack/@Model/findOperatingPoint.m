function [OP, varargout] = findOperatingPoint(this, varargin)
% FINDOPERATINGPOINT Finds the operating point of the model from
% specifications or simulation.
%
% [OP_PT, OP_REP] = this.findOperatingPoint(op_spec, linoptions)
% OP_PTS = this.findOperatingPoint(times,  linoptions)
%
% OP_SPEC  is an object containing the operating point specifications.
% LINOPTIONS is a linearization options object.
%
% OP_PT(S) is an object array containing the operating point(s).
% OP_REP   is an abject containing the operating point report.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/05 02:22:32 $

OP = [];

nout = max(nargout,1) - 1;
if nout > 0
  varargout(1:nout) = {[]};
end

ctrlMsgUtils.warning('SLControllib:modelpack:warnAbstractMethod',class(this));
