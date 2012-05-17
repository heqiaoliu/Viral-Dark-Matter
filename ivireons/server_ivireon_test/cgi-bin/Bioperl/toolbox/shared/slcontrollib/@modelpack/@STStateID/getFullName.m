function FullName = getFullName(this) 
% GETFULLNAME  method to return State full name. The full name is a
% conctenation of the State path and State name.
%
 
% Author(s): A. Stothert 21-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:41:19 $

Name = get(this,'Name');
Path = get(this,'Path');

%Check whether path is empty, if not tag a '/' on end to separate path and
%name
if numel(this) > 1
   %Vector of states
   idx = ~cellfun('isempty',Path);
   if any(idx)
      %Path is not empty, append path separator
      tmp = strcat({Path{idx}},'/');
      [Path{idx}] = deal(tmp{:});
   end
else
   %Single object
   if ~isempty(Path)
      Path = strcat(Path,'/');
   end
end

%Form full name
FullName = strcat(Path,Name);
