function checkLinks(this,DSArray)
%CHECKLINKS  Checks if new data sets added to a given LinkArray
%            are compatible with the existing data sets.
%
%   [LinkVars,SharedVars] = CHECKLINKS(LinkArray,DSArray) checks if 
%   the data sets in DSArray are compatible with the existing data 
%   sets in LinkArray and the existing variables in the parent data set. 
%   CHECKLINKS updates the "LinkedVariables" and "SharedVariables"
%   properties of the LinkArray.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:58 $

% Requirement: All linked data sets should have the same set of top-level 
%              variables and links (the Shared Variables)
errmsg = sprintf('Invalid value for data link %s. Expects cell array of data set handles.',this.Alias.Name);
LinkedVars = this.LinkedVariables;
SharedVars = this.SharedVariables;

% Quick exit if DSArray is empty
if isempty(DSArray)
   % No impact on linked vars or template
   return
elseif ~isa(DSArray,'cell')
   error(errmsg)
end

% Find nonempty entries in DSArray
idxDS = find(~cellfun('isempty',DSArray));
if isempty(idxDS)
   % No impact on linke dvars or template
   return
end

% If data link is empty, use first nonempty linked data set 
% to initialize SharedVars and LinkedVars lists
if isempty(SharedVars)
   % Empty data link. Use first nonempty linked data set as reference
   DSref = DSArray{idxDS(1)};
   if ~isa(DSref,'hds.AbstractDataSet')
      error(errmsg)
   end
   idxDS(1,:) = [];
   Vars = getvars(DSref);
   SharedVars = [Vars;getlinks(DSref)];
   LinkedVars = [Vars;getLinkedVars(DSref)];
end

% Check that all linked data sets have the same top-level variables (VARS)
% and update cumulative list DEPENDVARS of dependent variables
for ct=1:length(idxDS)
   d = DSArray{idxDS(ct)};
   sv = [getvars(d) ; getlinks(d)];
   dv = getLinkedVars(d);
   if ~isa(d,'hds.AbstractDataSet')
      error(errmsg)
   elseif ~isequal(sv,SharedVars)
      error('All data sets in a data link must contain the same variables.')
   elseif ~isempty(dv)
      [ia,ib] = utIntersect(dv,LinkedVars);
      if length(ia)<length(dv)
         LinkedVars = unique([LinkedVars;dv]);
      end
   end
end

% Update cached variable data
this.LinkedVariables = LinkedVars;
this.SharedVariables = SharedVars;

% If transparency is on, the Shared Variables should not clash
% with the variables visible from the parent node (to ensure
% unique fields in GETSAMPLE struct)
if strcmp(this.Transparency,'on')
   % Toggle transparency to force check
   this.Transparency = 'off';
   this.Transparency = 'on';  % warns about clashes
end
   
