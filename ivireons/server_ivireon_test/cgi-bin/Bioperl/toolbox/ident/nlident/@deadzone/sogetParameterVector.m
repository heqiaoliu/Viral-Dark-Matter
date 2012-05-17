function  th = sogetParameterVector(nlobj)
%sogetParameterVector returns the parameter vector of a single DEADZONE object.
%
%  th = sogetParameterVector(nlobj)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:58:12 $

% Author(s): Qinghua Zhang

if ~isinitialized(nlobj)
  th = [];
  return;
end

param = nlobj.prvParameters;
interval = param.Interval;

if isempty(interval) % Two sides
  th = [param.Center; param.Scale];
else % Single side or degenerate
  th = interval(isfinite(interval))';
end

% FILE END