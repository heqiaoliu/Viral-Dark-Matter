function removeModel(this, model)
% REMOVEMODEL Removes the MODEL from the list of models managed by the
% ModelManager.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/07/14 17:12:06 $

hasModel = false;
if ~isempty(this.Models)
   idx      = [this.Models.hModel] == model;
   hasModel = any(idx);
end

if hasModel
  % Decrement the reference counter for this model
  this.Models(idx).refCount = this.Models(idx).refCount - 1;
  if this.Models(idx).refCount < 1
     %Lost last reference to the model, delete it from the model manager.
     delete(model)
  end
end
end
