function dirs = getModelDependencies(modelName)
% GETMODELDEPENDENCIES static package function to return model path
% dependencies
%
 
% Author(s): A. Stothert 10-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/31 23:25:28 $

%Identify model path dependencies
[lWarnMsg,lWarnID] = lastwarn;
wState(1) = warning('off','Simulink:dependencies:SLVNVNotInstalled');
wState(2) = warning('off','Simulink:dependencies:NoMDLFile');
[files, missing, depfile] = dependencies.fileDependencyAnalysis(modelName);
if strcmp(wState(1).state,'on')
   warning('on','Simulink:dependencies:SLVNVNotInstalled');
end
if strcmp(wState(2).state,'on')
   warning('on','Simulink:dependencies:NoMDLFile');
end
lastwarn(lWarnMsg,lWarnID)

%Process the returned file dependencies to find dependent directories
if ~isempty(files)
   if ~iscell(files), files = {files}; end
   files = regexprep(files,'\\','/');  %Make path sep consistent on different platforms
   dirs = cell(size(files));
   for ct=1:numel(files)
      if exist(files{ct},'file')
         %Strip file name to get path
         dirs{ct} = regexprep(files{ct},'/[.]*[^/]*$','');
      end
   end
   dirs = setdiff(dirs,regexprep(pwd,'\\','/'));
else
   dirs = {};
end
end
