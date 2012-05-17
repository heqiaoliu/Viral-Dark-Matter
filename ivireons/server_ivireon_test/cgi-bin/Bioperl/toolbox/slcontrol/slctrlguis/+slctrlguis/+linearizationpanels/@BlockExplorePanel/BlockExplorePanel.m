%   Copyright 2008-2009 The MathWorks, Inc.
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2009/07/09 20:56:56 $
classdef (Hidden = true) BlockExplorePanel < slctrlguis.util.AbstractPanel
properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        ShowBlocksInLinearization = false;
        SelectedIndex = 0;
    end
    properties(SetAccess='private',GetAccess = 'private')
        BlockData;
        BlockList;
        BlockInd;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)
                obj.setPeer(com.mathworks.toolbox.slcontrol.LinearizationInspector.BlockExplorePanelPeer);
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,BlockList,BlockData)
            obj.BlockData = BlockData;
            obj.BlockList = BlockList;            
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            setData(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setShowBlocksInLinearization(obj,val)
            obj.ShowBlocksInLinearization = val;
            setData(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setData(obj)
            if obj.ShowBlocksInLinearization
                obj.BlockInd = find(strcmp(get(obj.BlockData,'InLinearizationPath'),'Yes'));
                blockList = obj.BlockList(obj.BlockInd);
            else
                obj.BlockInd = 1:numel(obj.BlockList);
                blockList = obj.BlockList;
            end
            
            if isempty(blockList)
                clearBlockList(obj.getPeer,obj.ShowBlocksInLinearization)
            else
                setBlockListData(obj.getPeer,blockList,obj.ShowBlocksInLinearization);
            end    
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [BlockData,BlockList] = getData(obj)
            BlockData = obj.BlockData;
            BlockList = obj.BlockList;
        end
       
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function BlockData = getSelectedBlockData(obj)
            BlockData = obj.BlockData(obj.BlockInd(obj.SelectedIndex));
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [FullName,Name] = getSelectedBlockName(obj)
            FullName = obj.BlockData(obj.BlockInd(obj.SelectedIndex)).FullBlockName;
            Name = obj.BlockList{obj.BlockInd(obj.SelectedIndex)};
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function installDefaultListeners(obj)
% Call the getPanel method to ensure that the panel has been
% created.
obj.getPanel;
Peer = obj.getPeer;
addCallbackListener(obj,Peer.getBlockSelectionCallback,{@LocalBlockSelection,obj})
addCallbackListener(obj,Peer.getPopupMenuCallback,{@LocalPlotPopup,obj})
addCallbackListener(obj,Peer.getHighlightPopupMenuCallback,{@LocalHighlightPopup,obj})
addCallbackListener(obj,Peer.getShowBlocksPopupMenuCallback,{@LocalShowBlocksPopup,obj})
addCallbackListener(obj,Peer.getHyperlinkCallback,{@LocalEvalHyperlink,obj})
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalBlockSelection(es,ed,obj)
idx = ed.selectedIndex;
obj.SelectedIndex = idx;
if idx == 0
    updateSummary(obj);
    obj.getPeer.setPlotBlockMenuEnabled(false);
else
    BlockData = obj.BlockData(obj.BlockInd(ed.selectedIndex));
    plotmenuenabled = isPlotAvailable(BlockData);
    setPlotBlockMenuEnabled(obj.getPeer,plotmenuenabled);
    updateSummary(obj);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHighlightPopup(es,idx,obj)

if idx == 0
    str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNotSelected');
    errordlg(str,'Simulink Control Design')
    return
end

LocalHighlightBlock(obj)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHighlightBlock(obj)
block = getSelectedBlockName(obj);
try
    set_param(bdroot(block),'HiliteAncestors','off');
    hilite_system(block,'find');
catch Ex %#ok<NASGU>
    block = regexprep(block,'\n','');
    str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNoLongerAvailableToHighlight',block);
    errordlg(str,'Simulink Control Design')
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPlotPopup(es,ed,obj)
idx = ed.selectedIndex;
if idx == 0
    str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNotSelected');
    errordlg(str,'Simulink Control Design')
    return
end

sys = getSystemData(obj.BlockData(obj.BlockInd(idx)));
if ~isa(sys,'ss')
    sys = usample(sys,20);
    if ~isa(sys,'ss')
        sys = ss(sys);
    end
end

figure;
switch char(ed.key)
    case 'Step'
        step(sys)
    case 'Bode'
        bode(sys)
    case 'BodeMag'
        bodemag(sys)
    case 'Impulse'
        impulse(sys)
    case 'Nyquist'
        nyquist(sys)
    case 'Sigma'
        sigma(sys)
    case 'Nichols'
        nichols(sys)
    case 'PZMap'
        pzmap(sys)
    case 'IOPZMap'
        iopzmap(sys)
    case 'LinearSimulation'
        lsim(sys)
    case 'InitialCondition'
        initial(sys,zeros(size(sys.a,1)))
end
r = gcr;
r.AxesGrid.Title = sprintf('%s - %s',r.AxesGrid.Title,obj.BlockList{idx});
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowBlocksPopup(es,ed,obj)
obj.ShowBlocksInLinearization = ed;
obj.setData;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalEvalHyperlink(es,ed,obj)
% Evaluate the hyperlink
if strcmp(ed.getEventType.toString, 'ACTIVATED')
    Description = char(ed.getDescription);
    typeind = findstr(Description,':');
    identifier = Description(1:typeind(1)-1);
    switch identifier;
        case 'block'
            LocalHighlightBlock(obj)
        otherwise

    end
end
end
