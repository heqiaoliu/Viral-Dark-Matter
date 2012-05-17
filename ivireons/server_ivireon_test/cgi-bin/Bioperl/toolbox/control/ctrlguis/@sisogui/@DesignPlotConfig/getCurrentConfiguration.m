function getCurrentConfiguration(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:28 $

Editors = find(this.SISODB.PlotEditors,'Visible','on');
numEditors = length(Editors);

% Note 3rd column should be in english translation handled in java class
for ct =1:numEditors
    L = SISODB.LoopData.L(Editors(ct).EditedLoop);
    VisEditorData{ct} = {sprintf('Plot %s', num2str(ct)), L.Name, LocalGetEditorType(Editors(ct))};
end

for ct = numEditors+1:6
    L = SISODB.LoopData.L(1);
    VisEditorData{ct} = {sprintf('Plot %s', num2str(ct)), L.Name, 'None'};
end
    

function str = LocalGetEditorType(Editor)

switch class(Editor)
    case sisogui.rlocuseditor
        str = 'Root Locus';
    case sisogui.bodeditorOL
        str = 'Open-Loop Bode';
    case sisogui.bodeditorF
        str = 'Closed-Loop Bode';
    case sisogui.nicholseditor
        str = 'Nichols';
end