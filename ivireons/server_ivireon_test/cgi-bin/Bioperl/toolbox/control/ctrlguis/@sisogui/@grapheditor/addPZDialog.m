function C = addPZDialog(Editor, GroupType, PZType)
% ADDPZDialog  Dialog to select which tunedfactor to add a pole/zero to

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2006/11/17 13:25:38 $

TunedFactors = Editor.LoopData.L(Editor.EditedLoop).TunedFactors;

% Find valid TunedFactors which can pzgroup can be added
ValidTF = handle(zeros(0,1));
for ct = 1:length(TunedFactors)
    if TunedFactors(ct).isAddpzAllowed(GroupType,PZType);
        ValidTF(end+1) = TunedFactors(ct);
    end
end

nTF = length(ValidTF);

if nTF == 0
    C = [];  % 'cant add pole/zero'
    %warndlg('Cannot add the selected pole/zero to a compensator','Add pole/zero','modal');
    msg1 = sprintf('Unable to add the selected pole/zero to a compensator for this loop.');
    msg2 = sprintf('Possible reasons include:');
    msg3 = sprintf('The compensators have a constrained structure which would be violated.');
    msg4 = sprintf('The compensators have a constrained structure with a native sample time that differs from the current sample time of the design.');
    msg5 = sprintf('There are no compensators that appear in series for this loop.');
    errordlg(sprintf('%s \n \n %s \n 1) %s \n 2) %s \n 3) %s \n', msg1, msg2,...
        msg3,msg4,msg5),sprintf('Add pole/zero'),'modal');
else
    if nTF == 1
        C = ValidTF;
    else
       %create dialog here 
        [Selection,ok] = listdlg('ListString',get(ValidTF,'Name'),...
            'SelectionMode','single', 'Name',xlate('Add Pole/Zero'));
        C = ValidTF(Selection);
    end
end