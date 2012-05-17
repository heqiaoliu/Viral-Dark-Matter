function name = findVariableNames(this,candidate)
% FINDVARIABLENAMES  Find variable names that are not used in base workspace
% and model workspaces of any loaded models.
%
 
% Author(s): Erman Korkut 14-Jul-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:22 $

% Construct the exclusion list
% Base workspace
list = evalin('base','who');
% Add model workspace(s) to the list
hws = get_param(this.Model,'ModelWorkspace');
modelvars = hws.whos; modelvars = {modelvars.name};
list = [list(:);modelvars(:)];
% Referenced models
for ct = 1:numel(this.NormalRefModels)
    hws = get_param(this.NormalRefModels{ct},'ModelWorkspace');
    modelvars = hws.whos; modelvars = {modelvars.name};
    list = [list(:);modelvars(:)];    
end
name = cell(1,numel(candidate));
for ct = 1:numel(candidate)
    name{ct} = genvarname(candidate{ct},list);
    % Add this name to the list
    list{end+1} = name{ct};    
end
