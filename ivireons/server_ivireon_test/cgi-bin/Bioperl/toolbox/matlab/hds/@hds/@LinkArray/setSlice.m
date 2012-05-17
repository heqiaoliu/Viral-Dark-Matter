function setSlice(this,Section,Slice,GridSize,Vars)
%SETSLICE  Modifies multi-dimensional slice of data set array or
%          of some variable therein.
%
%   SETSLICE(LINKARRAY,SECTION,SLICE,GRIDSIZE) modifies a portion
%   of the link array LINKARRAY.  SLICE is a cell array of data
%   sets.
%
%   SETSLICE(LINKARRAY,SECTION,SLICE,GRIDSIZE,VARS) modifies the
%   values of the variable VARS in the specified portion of the 
%   link array LINKARRAY.  SLICE is a struct array containing the
%   new variable values.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:05 $
if nargin==4
   % Modifying slice of data set array (data link)
   if isempty(this.Links)
      DSArray = cell([GridSize 1]);
   else
      DSArray = this.Links;
   end
   
   % Optimization: no-op for modifications of existing data sets
   if ~isequal(DSArray(Section{:}),Slice)
      % Validate data sets in slice
      this.checkLinks(Slice);
      % Modify slice
      DSArray(Section{:}) = Slice;
      % Update LinkArray data
      this.setArray(DSArray);
   end
else
   % Modifying data in all dependent data sets in specified 
   % data link slice
   % RE: Data set array cannot be empty in this case
   DSArray = this.Links(Section{:});
   SectionSize = size(DSArray);
   % Use first nonempty data set as template
   idx = find(~cellfun('isempty',this.Links));
   Template = this.Links{idx(1)};
   % Update contents of linked data sets in modified section
   NewSets = false;
   for ct=1:prod(SectionSize)
      if isempty(DSArray{ct})
         DS = copySkeleton(Template);
         DSArray{ct} = DS;
         NewSets = true;
      else
         DS = DSArray{ct};
      end
      setContents(DS,Slice(ct),Vars);
   end
   % Update link array
   if NewSets
      this.Links(Section{:}) = DSArray;
   end
end

