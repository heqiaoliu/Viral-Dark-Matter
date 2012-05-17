function status = isinitialized(nlobj)
%ISINITIALIZED True for initialized nonlinearity estimator.
%
%  For an array of nonlinearity estimator objects, ISINITIALIZED returns
%  True if all the estimators are initialized.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/11/09 16:24:01 $

% Author(s): Qinghua Zhang

if isscalar(nlobj)
  % If all fields of nlobj.Parameters, except LinearCoef and LinearSubspace (if exist),
  % are empty, then not initialized 
  
  pm = nlobj.Parameters;
  if isstruct(pm)
    if isfield(pm, 'LinearCoef')
      pm.LinearCoef = [];
    end
    if isfield(pm, 'LinearSubspace')
      pm.LinearSubspace = [];
    end
    status = ~all(cellfun(@isempty, struct2cell(pm)));
  else
    status = false;
  end
% Before the exception processing:
%   status = isstruct(nlobj.Parameters) && ...
%            ~all(cellfun(@isempty, struct2cell(nlobj.Parameters)));
                  
else
  % Note: isinitialized(subclass_obj) must be called.
  status = true;
  idnlfunVecFlag = isa(nlobj,'idnlfunVector');
  for ky=1:numel(nlobj)
    if  (idnlfunVecFlag && ~isinitialized(nlobj.ObjVector{ky})) ...
        || (~idnlfunVecFlag && ~isinitialized(nlobj(ky)))
      status = false;
      return
    end
  end
end

% Oct2009
% FILE END