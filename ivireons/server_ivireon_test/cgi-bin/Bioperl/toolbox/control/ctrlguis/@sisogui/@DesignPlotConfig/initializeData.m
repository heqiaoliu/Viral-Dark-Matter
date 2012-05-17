function initializeData(this)

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2006/06/20 20:02:19 $

L = this.SISODB.LoopData.L;


%%
TunedLoopTableData = {'None','None'};
% Tuned Loop Summary Table Data
for ct = 1:length(L)
    TunedLoopTableData(ct,:) = {L(ct).Name, L(ct).Description};
end
this.TunedLoopTableData = TunedLoopTableData;

% Note 3rd column of data should be in english translation handled in java class
if ~isempty(this.SISODB.PlotEditors)
    Editors = find(this.SISODB.PlotEditors,'Visible','on');
    numEditors = length(Editors);

    % Design Views Configuration Table Data
    for ct =1:numEditors
        Lc = this.SISODB.LoopData.L(Editors(ct).EditedLoop);
        DesignViewsTableData(ct,:) = {sprintf('Plot %s', num2str(ct)), Lc.Name, LocalGetEditorType(Editors(ct))};
    end
else
    numEditors = 0;
end

% Check if there are no loops
if isempty(L)
    LoopName = 'None';
else
    LoopName = L(1).Name;
end
    
for ct = numEditors+1:6
    DesignViewsTableData(ct,:) = {sprintf('Plot %s', num2str(ct)), LoopName, 'None'};
end
    
this.DesignViewsTableData = DesignViewsTableData;


%% Local Functions --------------------------------------------------------
function str = LocalGetEditorType(Editor)

switch class(Editor)
    case 'sisogui.rleditor'
        str = 'Root Locus';
    case 'sisogui.bodeditorOL'
        str = 'Open-Loop Bode';
    case 'sisogui.bodeditorF'
        str = 'Closed-Loop Bode';
    case 'sisogui.nicholseditor'
        str = 'Nichols';
end

