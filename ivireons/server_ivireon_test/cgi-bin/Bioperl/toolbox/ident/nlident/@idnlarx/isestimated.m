function status = isestimated(sys)
%ISESTIMATED true for estimated model.
%
%  ISESTIMATED(MODEL) returns 1 if MODEL is already estimated and
%  no property change has been made since last estimation,
%  returns 0 if the model has never been estimated or important property
%  changes have been made since the last estimation, or returns -1 if
%  minor changes have been made since the last estimation.
%  The minor changes are those of Focus and of IDNLMODEL.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:27 $

% Author(s): Qinghua Zhang

status = pvget(sys,'Estimated');
if status==0
  return
end

ny = size(sys, 'ny');
nlobj = sys.Nonlinearity;
[nlout, nlin] = size(nlobj);
badnlflag = (ny~=nlout) || ~isinitialized(nlobj) || any(isnan(nlin(:)));
if ~badnlflag
  [dum, arxregdim] = reginfo(sys.na, sys.nb, sys.nk, sys.CustomRegressors);
  badnlflag = numel(arxregdim)~=numel(nlin) || ~all(arxregdim(:)==nlin(:));
end

status = status * double(~badnlflag);

% FILE END