function Port = findPort(this,PortList,Name,Exact) 
% FINDPORT  private method to return particular port(s)
%
% Input:
%   PortList - a vector of STPortID objects to search through
%   Name     - a string with the name of the port to find
%   Exact    - a boolean flag, when true an exact match is required
%
 
% Author(s): A. Stothert 26-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:52 $

%Check number of arguments
if nargin ~= 4
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','3')
end

%Check argument types
if ~isa(PortList,'modelpack.STPortID')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','PortList','modelpack.STPortID')
end
if ~ischar(Name)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Name','string')
end

%Look for full port names that contain the search string
if Exact
   idx = strcmp(PortList.getFullName,Name);
else
   idx = ~cellfun('isempty',strfind(PortList.getFullName,Name));
end
Port = PortList(idx);