function this = OpenLoopConfigDialog(LoopData)
%OpenLoopConfigDialog Constructor

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/02/06 19:50:40 $

this = sisogui.OpenLoopConfigDialog;

this.LoopData = LoopData;

this.Target = 1;

L = LoopData.L;

%% Filter out the feedback loops
FBFlag = get(L,{'Feedback'});
indfb = find([FBFlag{:}]);
if isempty(indfb)
    warndlg(sprintf('The current control architecture does not contain any feedback loops.'),'Loop Configuration');
else
    FeedbackLoops = L(indfb);

    for ct = 1:length(FeedbackLoops)
        LoopConfig(ct) = FeedbackLoops(ct).LoopConfig;
    end

    this.FeedbackLoops = FeedbackLoops;
    this.LoopConfig =  LoopConfig;

    this.buildDialog;
    this.refreshTable;

    %% Get the handle to the CETM
    CETMFrame = slctrlexplorer;
    CETMFrame.setBlocked(true,[]);
    awtinvoke(this.Handles.Frame,'setLocationRelativeTo',slctrlexplorer);
    awtinvoke(this.Handles.Frame,'show()');
end