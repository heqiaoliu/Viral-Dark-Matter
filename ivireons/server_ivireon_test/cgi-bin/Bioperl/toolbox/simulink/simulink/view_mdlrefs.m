function varargout = view_mdlrefs(varargin)
% VIEW_MDLREFS Display the model reference dependency graph
%
%   Input: 
%      modelName - Name of a Simulink model
%
%   view_mdlrefs('modelName' or modelHandle) will display the 
%   model reference dependency graph for a model. The nodes 
%   in the graph represent Simulink models or libraries. 
%   The directed lines indicate dependencies. For more information,
%   see the mdlref_depgraph demo.
%
%   Copyright 1994-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.12 $
  
%   Inputs for internal use only:
%     varargin{1}: skipLicenseCheck - If true, skip license check.   
%
%   Output for internal use only:
%      varargout{1} - dependency viewer handle
%
    if(nargin == 0)
        [ui, tab] = depview;
    else
        [ui, tab] = depview(varargin{:}, 'FileDependenciesExcludingLibraries', true);
    end

    varargout{1} = ui;
    varargout{2} = tab;
end % view_mdlrefs