function Group = groupref(Group,indices)
%GROUPREF  Manage I/O groups in subscripted references
%
%   SUBGROUP = GROUPREF(GROUP,INDICES)

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:35 $

% RE: INDICES assumed to be a vector of integers
CellFlag = isa(Group,'cell');
if CellFlag
   GroupNames = Group(:,2);
else
   GroupNames = fieldnames(Group);
end

if ~isempty(GroupNames) && ~strcmp(indices,':'),
   ikeep = [];
   if CellFlag
      GroupChannels = Group(:,1);
   else
      GroupChannels = struct2cell(Group);
   end
   
   % Get rid of logical indices
   if islogical(indices), 
      indices = find(indices); 
   end
   
   % For each group, delete channels that don't belong to INDICES
   % and account for repeated indices
   for i=1:length(GroupNames)
      % RE: Cannot use intersect because of repeated indices, e.g, 
      %     ch=3 and indices=[3 1 3] -> newch = [1 3]
      ch = GroupChannels{i};
      newch = [];
      for j=1:length(ch)
         newch = [newch , find(ch(j)==indices)]; %#ok<AGROW>
      end
      if ~isempty(newch)
         ikeep = [ikeep i]; %#ok<AGROW>
         GroupChannels{i} = newch;
      end
   end
   
   % Update group
   if CellFlag
      Group = [GroupChannels(ikeep,:),GroupNames(ikeep,:)];
   else
      Group = cell2struct(GroupChannels(ikeep,:),GroupNames(ikeep,:),1);
   end
end
