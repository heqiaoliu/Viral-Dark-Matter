function deleteModel(this,hModel) 
% DELETEMODEL delete a model stored in the model manager
%
 
% Author(s): A. Stothert 16-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/07/14 17:12:04 $

hasModel = false;
if ~isempty(this.Models)
   idx      = [this.Models.hModel] == hModel;
   hasModel = any(idx);
end

if hasModel
   %Remove model from the model manager.
   this.Models(idx) = [];
   
   %Remove any listeners to this model
   hSrc                     = get(this.ModelListeners,{'SourceObject'});
   hSrc                     = [hSrc{:}];
   idx                      = hSrc == hModel;
   this.ModelListeners(idx) = [];
   
   %Delete the model
   delete(hModel)
end