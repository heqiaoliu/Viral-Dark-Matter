function fList = ConvertPathToUNC(fList)
%CONVERTPATHTOUNC create UNC path for files/directories
%
% fList = ConvertPathToUNC(fList)
%
% A Windows only utility function to convert DOS style paths to UNC, e.g.,
% c:\Temp -> \\hostname\c$\Temp, mapped drives are also converted.
% 
% Inputs:
%   fList - a path string (or cell array of similar) to convert, paths
%           that don't start with drive letters are ignored.
%
% Outputs:
%   fList - the converted UNC path(s)
%

%   $Revision: 1.1.8.2 $ $Date: 2008/05/31 23:25:36 $
%   Copyright 2008 The MathWorks, Inc.

if ispc
   %Only create UNC for Windows Systems
   if ~iscell(fList), fList = {fList}; end
   
   %Basic argument checking
   if ~iscellstr(fList)
      ctrlMsgUtils.error('SLControllib:slcontrol:ConvertToUNCArgumentError')
   end
   
   [mappedDrive, split] = regexpi(fList, '^[a-z]:', 'match', 'split', 'once');
   hostname = getenv('COMPUTERNAME');
   idx = ~cellfun('isempty',mappedDrive(:)');
   for ct = find(idx)
      [s, r] = system(['net use ' mappedDrive{ct}]);
      if s
         %Drive is not mapped, treat as local drive
         fList{ct} = ['\\', hostname, '\', mappedDrive{ct}(1), '$', split{ct}{2}];
      else
         %Drive is mapped
         location = regexp(r, '\\\\.*', 'dotexceptnewline', 'match', 'once');
         fList{ct} = [location, split{ct}{2}];
      end
   end
end
end