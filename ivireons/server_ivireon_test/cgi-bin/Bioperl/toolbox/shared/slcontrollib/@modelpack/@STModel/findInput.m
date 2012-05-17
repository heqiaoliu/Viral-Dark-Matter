function Ports = findInput(this,Search,Exact) 
% FINDINPUT  method to find particular input(s)
%
% ports = this.findInput(Search,Exact) 
%
% Input:
%   Search - string used to find matching input (the inputs are searched on 
%            the output fullname) or numerical index of input to return
%   Exact  - optional logical, if true an exact match is required, default
%            is true
%

% Author(s): A. Stothert 26-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:12 $

%Check number of arguments
if nargin < 2 || nargin > 3
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','1 or 2');
end

%Check argument types
if ~ischar(Search) && ~isnumeric(Search)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Search','double or string')
end
%Set Exact to default if omitted
if nargin == 2, Exact = false; end
if ~islogical(Exact)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Exact','logical')
end

idx = strcmp(this.IOs.getType,'Input');
PortList = this.IOs(idx);
if ~isempty(PortList)
   if isnumeric(Search)
      Ports = PortList(Search(:));
   else
      Ports = findPort(this,PortList,Search,Exact);
   end
else
   Ports = [];
end