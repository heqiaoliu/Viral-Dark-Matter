function Param = findParameter(this,Search,Exact) 
% FINDPARAMETER  method to find particular parameter(s)
%
% param = this.findParameter(Search,Exact)
%
% Input:
%   Search - string used to find matching parameter (the parameters are searched on 
%            the fullname) or numerical index of parameter to return
%   Exact  - optional boolean, if true an exact match is required, default
%            is true
%
 
% Author(s): A. Stothert 27-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:17 $

%Check number of arguments
if nargin < 2 || nargin > 3
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','1 or 2')
end

%Check argument types
if ~ischar(Search) && ~isnumeric(Search)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Search','double or string');
end
%Set Exact to default if omitted
if nargin == 2, Exact = false; end
if ~islogical(Exact)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Exact','logical');
end

if ~isempty(this.Parameters)
   if isnumeric(Search)
      Param = this.Parameters(Search(:));
   else
      if Exact
         idx = strcmp(this.Parameters.getFullName,Search);
      else
         %Look for full parameter names that contain the search string
         idx = ~cellfun('isempty',strfind(this.Parameters.getFullName,Search));
      end
      Param = this.Parameters(idx);
   end
else
   Param = [];
end