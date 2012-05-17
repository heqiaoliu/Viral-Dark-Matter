classdef ModelLinearizationParamMgr < handle
%

% Author(s): A. Stothert 31-Mar-2010
% Copyright 2010 MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:56:13 $

% MODELLINEARIZATIONPARAMMGR manage linearization parameter instances for a
% model
%
% Class is singleton and contains a list of one linearization parameter manager 
% class per model

properties(GetAccess = private, SetAccess = private)
   ParamMgrList
end % private properties

methods(Access = protected)
   function obj = ModelLinearizationParamMgr
      %MODELLINEARIZATIOPARAMMGR constructor
      %
      %Protected for singleton implementation
   end
   function mgr = findParameterManager(this,model)
      % FINDPARAMETERMANAGER method to find a linearization parameter manager
      % for a given model
      %
  
      if ~isempty(this.ParamMgrList)
         %Remove any deleted Mgrs from the list
         this.ParamMgrList = this.ParamMgrList(isvalid(this.ParamMgrList));
         %Search list of known parameter managers for one for the specified model
         if isempty(this.ParamMgrList)
            idx = false;
         else
            allM = {this.ParamMgrList.Model};
            idx  = strcmpi(allM,model); %Simulink model names are case insensitive
         end
      else
         idx = false;
      end
      
      if any(idx)
         %Found a parameter manager for the specified model return it
         mgr = this.ParamMgrList(idx);
      else
         %No execution engine found for the specified model, create one.
         mgr = slcontrollib.mdlcfg.ParameterManager(model);
         this.ParamMgrList = [this.ParamMgrList; mgr];
      end
   end
end % protected methods

methods(Static = true)
   function obj = getInstance(model)
      % GETINSTANCE return a linearization parameter manager for a given
      % model
      %
      persistent theInstance
      mlock
      
      if nargin < 1 || ~ischar(model)
         error('id:id','The getInstance method requires a model name argument.')
      end
      
      if isempty(theInstance)
         theInstance = linearize.ModelLinearizationParamMgr;
      end
      obj = theInstance.findParameterManager(model);
   end
end % static methods

end
