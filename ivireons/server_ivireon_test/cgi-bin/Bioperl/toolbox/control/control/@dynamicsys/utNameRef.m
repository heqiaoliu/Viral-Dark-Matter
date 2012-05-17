function indices = utNameRef(L,indstr,ioflag)
% Turn references by name into regular subscripts
%
%   IND = UTNAMEREF(L,STRCELL,IOFLAG)  takes a cell vector of 
%   strings STRCELL and looks for matching I/O channel or 
%   I/O group names in the LTI object L.  The search is 
%   carried out among the outputs if IOFLAG=1, and among 
%   the inputs if IOFLAG=2.
%   
%   See also SUBSREF, SUSBASGN.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 14:23:29 $

% Make sure input is a cell array of strings
if isnumeric(indstr) || islogical(indstr) || (ischar(indstr) && strcmp(indstr,':'))
   indices = indstr;   return
elseif ischar(indstr)
   indstr = cellstr(indstr);
elseif ~iscellstr(indstr)
   ctrlMsgUtils.error('Control:ltiobject:subsref1',ioflag)
end
if ~isvector(indstr)
   ctrlMsgUtils.error('Control:ltiobject:subsref6')
end

% Set name lists for search based on IOFLAG
if ioflag==1
   ChannelNames = L.OutputName;
   Groups = getgroup(L.OutputGroup);
else
   ChannelNames = L.InputName;
   Groups = getgroup(L.InputGroup);
end
GroupNames = fieldnames(Groups);

% Perform a string-by-string matching to respect the
% referencing order
indices = zeros(1,0);
nu = length(ChannelNames);
for ix = 1:length(indstr)
   str = indstr{ix};
   if isempty(str),
      ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
   end
   % Match against channel names and group names
   imatch = LocalFindMatch(str,[ChannelNames;GroupNames]);
   imatch1 = imatch(imatch<=nu);     % Channel name matches
   imatch2 = imatch(imatch>nu)-nu;   % Group name matches
   nhits1 = length(imatch1);
   nhits2 = length(imatch2);
   % Error checks
   if ~nhits1 && ~nhits2,
      ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
   elseif nhits1 && nhits2,
      ctrlMsgUtils.error('Control:ltiobject:subsref8',str)
   elseif nhits2,
      % Group match
      if nhits2>1,
         ctrlMsgUtils.warning('Control:ltiobject:MutipleGroupMatch',str)
      end
      for ct=1:length(imatch2)
         indices = [indices , Groups.(GroupNames{imatch2(ct)})]; %#ok<AGROW>
      end
   else
      % Channel match
      if nhits1>1,
         ctrlMsgUtils.warning('Control:ltiobject:MutipleChannelMatch',str)
      end
      indices = [indices , imatch1(:)']; %#ok<AGROW>
   end
end


%%%%%%%%%%%%%%%%%%
% LocalFindMatch %
%%%%%%%%%%%%%%%%%%
function imatch = LocalFindMatch(str,names)
% Find all NAMES matching STR using a cascade of matching filters
nchar = length(str);

% 1) Start with partial context-insensitive matches
imatch = find(strncmpi(str,names,nchar));

% 2) Use case-sensitive partial matching to further narrow hits
if length(imatch)>1
   icsm = find(strncmp(str,names(imatch),nchar));
   if ~isempty(icsm)
      imatch = imatch(icsm);
   end
end

% 3) Look for exact match if there are still multiple hits
if length(imatch)>1
   iexact = find(cellfun('length',names(imatch))==nchar);
   if ~isempty(iexact)
      imatch = imatch(iexact);
   end
end

