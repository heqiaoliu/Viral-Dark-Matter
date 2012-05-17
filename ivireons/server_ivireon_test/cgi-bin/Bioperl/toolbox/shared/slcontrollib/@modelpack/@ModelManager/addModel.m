function h = addModel(this, model, name)
% ADDMODEL Adds the MODEL of given NAME to the list of models managed by the
% ModelManager.  If the MODEL already exists, returns the handle to it
% instead.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/07/14 17:12:03 $

if nargin < 3, name = model.getName; end

newModel = true;
if ~isempty(this.Models)
   hModels  = [this.Models.hModel];
   idxModel = strcmp(hModels.getName,name);
   newModel = ~any(idxModel);
end

if newModel
  % Store the handle of the new model object.
  this.Models = [this.Models; struct('hModel',model,'refCount',1)];
  h = model;
  %Add delete listener for the model object
  this.ModelListeners = [this.ModelListeners; ...
     handle.listener(h,'ObjectBeingDestroyed', {@localDeleteModel this})];
else
  % Return model handle as it already exists and bump reference count
  h = hModels(idxModel);
  this.Models(idxModel).refCount = this.Models(idxModel).refCount + 1;
end
end

function localDeleteModel(hSrc,hData,this)
%Model is being deleted outside of model manager, possibly by a client.
%Delete the model from the model manager

deleteModel(this,hSrc)
end