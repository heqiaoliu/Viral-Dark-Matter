function dirs = findDepend(mdl)
% FINDDEPEND returns the path dependencies associated with a Simulink
% model.

% Author(s): Erman Korkut 10-Jun-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:33 $

if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',mdl))
   ctrlMsgUtils.error('Slcontrol:frest:errOpenModel',mdl)
end

dirs = parallelsim.getModelDependencies(mdl);
