function err = nncheckpt(p,t,pname,tname)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if nargin < 4, nnerr.throw('Not enough arguments.'); end

err = [];

err = nntype.data('check',p,pname);
if ~isempty(err), return; end
err = nntype.data('check',t,tname);
if ~isempty(err), return; end

if isnumeric(p) ~= isnumeric(t)
  err = [pname ' and ' tname ' must be both numeric or both cell.'];
  return;
end
if iscell(p) ~= iscell(t)
  err = [pname ' and ' tname ' must be both numeric or both cell.'];
  return
end

if isnumeric(p)
  Qp = size(p,2);
  Qt = size(t,2);
  if (Qp ~= Qt)
    err = [pname ' and ' tname ' have different numbers of columns.'];
    return
  end
else
  TSp = size(p,2);
  TSt = size(t,2);
  if (TSp ~= TSt)
    err = [pname ' and ' tname ' have different numbers of columns.'];
    return
  end
  Qp = size(p{1,1},2);
  Qt = size(t{1,1},2);
  if (Qp ~= Qt)
    err = [pname '{i,j} and ' tname '{i,j} have different numbers of columns.'];
    return
  end
end
