function lv = getLinkedVars(this,Link)
%GETLINKEDVARS  Get list of all variables visible through data links.
%
%   LV = GETLINKEDVARS(D) returns all variables that belong to data 
%   sets linked to the data set D, or equivalently all variables
%   that can be accessed through the link variables in D.
%
%   LV = GETLINKEDVARS(D,LINKNAME) returns all variables accessible
%   through the data link with name LINKNAME. The data link name
%   is specified at construction or when adding a new link with 
%   ADDLINK.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:26 $
if isempty(this.Children_)
   lv = [];
else
   if nargin==1
      lv = get(this.Children_,{'LinkedVariables'});
      % REVISIT: workaround empty handles being [0x1] double
      lv = lv(cellfun('length',lv)>0);
      lv = cat(1,lv{:});
   else
      Link = findlink(this,Link);
      LinkArray = find(this.Children_,'Alias',Link);
      if isempty(LinkArray)
         lv = [];
      else
         lv = LinkArray.LinkedVariables;
      end
   end
end