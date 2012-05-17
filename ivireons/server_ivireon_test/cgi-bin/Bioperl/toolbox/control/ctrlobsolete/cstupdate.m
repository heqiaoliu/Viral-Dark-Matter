function cstupdate(diagram_name)
%CSTUPDATE  Updates older versions of Control System Toolbox blocks.
%
%   CSTUPDATE('DiagramName') searches the Simulink model specified
%   by the string 'DiagramName' for LTI Blocks, Input Point, and 
%   Output Point Blocks.  Older versions of these blocks are replaced 
%   by their current versions.  Note that the model must be open 
%   prior to calling CSTUPDATE.

%   Karen Gondoly, 7-24-98
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/11/09 19:48:36 $

if ~isempty(nargchk(1,1,nargin)),
   error('You must specify a model name to update.')
elseif length(diagram_name)>4 && strcmpi(diagram_name(end-3:end),'.mdl')
   diagram_name = diagram_name(1:end-4);
end

if isempty(find_system('SearchDepth',0,'Name',diagram_name)),
  error('You must open the model ''%s'' first before using cstupdate.',diagram_name)
end

%---Make sure the I/O Points and LTI Block are loaded
closeLTIflag=0;

if isempty(find_system('Name','cstblocks')) || isempty(find_system('Name','slctrlobsolete'))
   load_system('cstblocks');
   load_system('slctrlobsolete');
   closeLTIflag=1;
end

closeSLflag=0;
%---Make sure the diagram, itself, is open
if isempty(find_system('Name',diagram_name)),
   load_system(diagram_name);
   closeSLflag=1;
end

allLTIblks = find_system(diagram_name,'LookUnderMasks','all','MaskType','LTI Block');

%---Replace Input Point blocks that do not have Terminators.
allInblks = find_system(diagram_name,'LookUnderMasks','all','MaskType','InputPoint');
if ~isempty(allInblks) && isempty(find_system(allLTIblks,'BlockType','Terminator')),
   %---Have to loop over the remaining blocks, in case the user has entered
   % some new Input Point blocks before the old ones got updated!
   for ct=1:length(allInblks),
      if isempty(find_system(allInblks{ct},'BlockType','Terminator'))
         NewInBlocks = replace_block(getfullname(allInblks{ct}), ...
            'Name',get_param(allInblks {ct},'Name'), ...
            'slctrlobsolete/Input Point','noprompt');
         connectline('open',NewInBlocks{1});
      end % if isempty(Terminator...)
   end % for ct
end % if ~isempty(allInblks) ...

%---Replace all Output Point blocks, just in case
NewOutBlocks = replace_block(diagram_name,'MaskType','OutputPoint', ...
   'slctrlobsolete/Output Point','noprompt');
for ct=1:length(NewOutBlocks)
   connectline('open',NewOutBlocks{ct});
end

%---For LTI Blocks, make sure to retain current block values
MaskStrs = get_param(allLTIblks,'MaskValueString');
NewBlocks = replace_block(diagram_name,'MaskType','LTI Block', ...
   'cstblocks/LTI System','noprompt');
for ct=1:length(MaskStrs),
   set_param(NewBlocks{ct},'MaskValueString',MaskStrs{ct});
end

if closeLTIflag, 
   close_system('cstblocks'); 
   close_system('slctrlobsolete');
end
if closeSLflag, 
   close_system(diagram_name,1); 
end
