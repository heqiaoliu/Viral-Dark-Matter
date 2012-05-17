function pDependencies = getPathsFromUI(this)
% GETPATHSFROMUI  utility method to get the path dependencies from the GUI
%
% Distinct method from setModelData as may be called prior to apply button
% being pressed, e.g., when dependency checker is run
 
% Author(s): A. Stothert 04-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/31 23:25:39 $

%Get raw string representation displayed in GUI
strDepend = char(this.Dialog.getParallelOptionPanel.getFields);
idx = regexp(strDepend,'[\n;]');  %Path separated by new line or ;
nP = numel(idx)+1;
pDependencies = cell(nP,1);
if nP > 1
   %Multiple paths, get the first path
   pDependencies{1} = strDepend(1:idx(1)-1);
else
   %Only one path specified
   pDependencies{1} = strDepend;
end
if nP > 2
   %More than 2 paths, extract the middle paths
   for ct=2:nP-1
      pDependencies{ct} = strDepend(idx(ct-1)+1:idx(ct)-1);
   end
end
if nP > 1
   %Only last path left to extract
   pDependencies{end} = strDepend(idx(end)+1:end);
end

%Strip out any leading or trailing spaces
pDependencies = regexprep(pDependencies,'[\s]+$','');  %Trailing spaces
pDependencies = regexprep(pDependencies,'^[\s]+','');  %Leading spaces

%Remove any path that is the noDependency message
strNoDepend = ctrlMsgUtils.message('SLControllib:slcontrol:warnNoPathDependencies'); 
idx = strncmp(pDependencies,strNoDepend,length(strNoDepend));
if any(idx)
   pDependencies(idx) = [];
end

%Remove any empty string paths
idx = cellfun('isempty',pDependencies);
if any(idx), pDependencies(idx) = []; end
   
end



