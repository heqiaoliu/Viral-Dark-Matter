function status = isestimated(sys)
%ISESTIMATED True for estimated model.
%
%  ISESTIMATED(MODEL) returns 1 if MODEL is already estimated and
%  no property change has been made since last estimation,
%  returns 0 if the model has never been estimated or important property
%  changes have been made since the last estimation, or returns -1 if
%  minor changes have been made since the last estimation.
%  The minor changes are those of the properties of IDNLMODEL.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:00:25 $

% Author(s): Qinghua Zhang

status = pvget(sys,'Estimated');
if status==0
  return
end

[ny, nu] = size(sys);

unl = sys.InputNonlinearity;
[nlout, nlin] = size(unl);
badnlflag = (nu~=nlout) || ~isinitialized(unl) || any(isnan(nlin(:))) || any(nlin(:)~=1);

if ~badnlflag
  ynl = sys.OutputNonlinearity;
  [nlout, nlin] = size(ynl);
  badnlflag = (ny~=nlout) || ~isinitialized(ynl) || any(isnan(nlin(:))) || any(nlin(:)~=1);
end

if ~badnlflag
  b = pvget(sys, 'b');
  f = pvget(sys, 'f');
  for k=1:(ny*nu)
    if any(isnan(b{k}(:))) || any(isnan(f{k}(:)))
      badnlflag = true;
      break
    end
  end 
end

status = status * double(~badnlflag);

% FILE END