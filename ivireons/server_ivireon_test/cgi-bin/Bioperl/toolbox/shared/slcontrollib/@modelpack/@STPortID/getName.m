function Name = getName(this) 
% GETNAME  method to return Port name
%
 
% Author(s): A. Stothert 21-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:41:12 $


Name = strcat(get(this,'Name'),':');
if numel(this) > 1
   Name = strcat(Name,cellfun(@num2str,get(this,'PortNumber')));
else
   Name = sprintf('%s%d',Name,this.PortNumber);
end
