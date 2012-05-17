function State = findState(this,Search,Exact) 
% FINDSTATE  method to find particular state(s)
%
% state = this.findState(Search,Exact)
%
% Input:
%   Search - string used to find matching state (the states are searched on 
%            the states fullname) or numerical index of state to return
%   Exact  - optional boolean, if true an exact match is required, default
%            is true
%
 
% Author(s): A. Stothert 27-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:19 $

%Check number of arguments
if nargin < 2 || nargin > 3
   ctrlMSgUtils.error('SLControllib:modelpack:errNumArguments','1 or 2')
end

%Check argument types
if ~ischar(Search) && ~isnumeric(Search)
   ctrlMsgUtils.errpr('SLControllib:modelpack:errArgumentType','Search','double or string');
end
%Set Exact to default if omitted
if nargin == 2, Exact = false; end
if ~islogical(Exact)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Exact','logical')
end

if ~isempty(this.States)
   if isnumeric(Search)
      State = this.States(Search(:));
   else
      if Exact
         idx = strcmp(this.States.getFullName,Search);
      else
         %Look for full state names that contain the search string
         idx = ~cellfun('isempty',strfind(this.States.getFullName,Search));
      end
      State = this.States(idx);
   end
else
   State = [];
end