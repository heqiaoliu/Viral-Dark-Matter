function dispGroup(sys)
% Creates display for I/O groups

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:46 $
disp(FormatGroup(getgroup(sys.InputGroup_),xlate('Input groups:')))
disp(FormatGroup(getgroup(sys.OutputGroup_),xlate('Output groups:')))
end

%------------
function Display = FormatGroup(Group,Title)
Blank = ' ';
Names = fieldnames(Group);
ng = length(Names);
if ng>0
   Channels = cell(ng,1);
   for i=1:ng,
      str = sprintf('%d,',Group.(Names{i}));
      Channels{i} = str(1:end-1);
   end
   Names = strjust(strvcat(xlate('Name'),char(Names)),'center'); %#ok<*VCAT>
   Channels = strjust(strvcat(xlate('Channels'),char(Channels)),'center');
   Display = strvcat(Title,...
      [Blank(ones(ng+1,4)) , Names , ...
         Blank(ones(ng+1,4)) , Channels],' ');
else
   Display = '';
end
end
