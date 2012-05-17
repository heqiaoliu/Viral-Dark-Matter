classdef CheckBlkExecutionManager < handle
 
% Author(s): A. Stothert 20-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:56:12 $

% CHECKBLKEXECUTIONMANAGER manage execution of frequency domain check
% blocks
%
% Class is singleton and contains list of one execution engine per model
%

properties(GetAccess = private, SetAccess = private)
   EngineList
   ModelListeners
end % private properties

methods(Access = protected)
   function obj = CheckBlkExecutionManager
      %CHECKBLKEXECUTIONMANAGER constructor
      %
      %Protected for singleton implementation
   end
   function eng = findEngine(this,model)
      % FINDENGINE method to find an execution engine for a given model
      %
      
      if ~isempty(this.EngineList)
         %Search list of known engines for one for the specified model
         allM = get(this.EngineList,{'Model'});
         idx  = strcmp(allM,model);
      else
         idx = false;
      end
      if any(idx)
         %Found an execution engine for the specified model return it
         eng = this.EngineList(idx);
      else
         %No execution engine found for the specified model, create one.
         eng = linearize.CheckBlkExecutionEngine(model);
         this.EngineList = [this.EngineList; eng];
         %Create listener to delete execution engine if model is closed
         hMdl = get_param(model,'Object');
         L = handle.listener(hMdl,'CloseEvent', @(hSrc,hData) deleteEngine(this,hSrc,eng));
         this.ModelListeners = [this.ModelListeners; L];
      end
   end
   function deleteEngine(this,hSrc,eng)
      % DELETEENGINE delete a model execution engine
      %
      %
      
      %Remove specified engine from the engine list and delete it
      this.EngineList = this.EngineList(this.EngineList ~= eng);
      delete(eng)
      %Clean up listener for model
      allSrc = get(this.ModelListeners,{'SourceObject'});
      allSrc = [allSrc{:}];
      this.ModelListeners = this.ModelListeners(allSrc ~= hSrc);
   end
end % protected methods

methods(Static = true)
   function obj = getInstance(model)
      % GETINSTANCE return an check block execution engine for a given
      % model
      %
      persistent theInstance
      mlock 
      
      if nargin < 1 || ~ischar(model)
         error('id:id','The getInstance method requires a model name argument.')
      end
      
      if isempty(theInstance)
         theInstance = linearize.CheckBlkExecutionManager;
      end
      obj = theInstance.findEngine(model);
   end
end % static methods

end
