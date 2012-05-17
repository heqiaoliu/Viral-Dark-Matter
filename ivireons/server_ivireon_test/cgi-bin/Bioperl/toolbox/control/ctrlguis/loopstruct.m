function Diagram = loopstruct(AxisHandle, ConfigData, Render, LoopConfig)
%LOOPSTRUCT  Draws feedback loop configuration.
%
%   Diagram = LOOPSTRUCT(ConfigData,AxisHandle,Render,LoopConfig) 
% 
%   Available RENDERs include
%     1) 'plain':  just the loop topology sketch
%     2) 'signal': include signal lines
%     3) 'labels': include labels
%     4) 'editlabels': include editable labels
%
%   If compensator index(Compindx) is supplied, the diagram retuned is 
%   one with inactive blocks grayed out for open loop with respect to Compindx

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $  $Date: 2008/10/31 05:55:42 $

if ~isa(ConfigData,'sisodata.design')
    ConfigData = struct('Configuration',ConfigData);
    LoopConfig = [];
    Render = 'plain';
end
   
% Delete all children
kids = get(AxisHandle,'Children');
delete(kids(ishghandle(kids)))

% Draw Block Diagram
Diagram = LocalDrawBlockDiagram(ConfigData, AxisHandle, Render);

% Find Inactive Blocks and grey out
if ~isempty(LoopConfig)
    config = ConfigData.Configuration;
    LoopStatus = false(length(ConfigData.Tuned),1);
    idxLoop = find(strcmp(LoopConfig.OpenLoop.BlockName,ConfigData.Tuned));
    LoopStatus(idxLoop) = true;

    for ct = 1:length(LoopConfig.LoopOpenings)
        idxCom = find(strcmp(LoopConfig.LoopOpenings(ct).BlockName,ConfigData.Tuned));
        LoopStatus(idxCom) = ~LoopConfig.LoopOpenings(ct).Status;
    end
        
    OLIC = getolic(config, LoopStatus);
    [InactiveBlocks, InactiveConnections, InactiveSignals] = findinactive(Diagram, idxLoop, OLIC);
    Diagram = setinactive(InactiveBlocks, InactiveConnections, InactiveSignals, Diagram);
end

%-----------------------Local Functions-----------------------------------%

% ------------------------------------------------------------------------%
% Function: LocalDrawBlockDiagram
% Purpose: Draws BlockDiagram for a configuration
% ------------------------------------------------------------------------%     
function Diagram = LocalDrawBlockDiagram(ConfigData, AxisHandle, Render)


% Render Mode
switch Render
    case 'plain'
        SigFlag = false;
        LabelFlag = false;
        EditFlag = false;
    case 'signal'
        SigFlag = true;
        LabelFlag = false;
        EditFlag = false;
    case 'labels'
        SigFlag = true;
        LabelFlag = true;
        EditFlag = false;
    case 'editlabels'
        SigFlag = true;
        LabelFlag = true;
        EditFlag = true;
    otherwise
        SigFlag = false;
        LabelFlag = false;
        EditFlag = false;
end


% % Define Colors
% ColorC = [1 0.45 0.45]; %Feedback Blocks
% ColorF = [0 0.85 0]; %FeedForward/Prefilter Blocks
% ColorG = [1 1 .8]; % Fixed Blocks

% B=Blocks, L=Lines, S=Sums, Signals=Signals
Diagram = struct('B',[], 'L', [], 'S', [], 'Signals', []);

% Use identifiers for signals rather then the names
tempconfigdata = sisoinit(ConfigData.Configuration);
ConfigData.Input = tempconfigdata.Input;
ConfigData.Output = tempconfigdata.Output;



switch ConfigData.Configuration
    case 1   % Configuration 1
        Diagram = drawconfig1(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);

    case 2   % Configuration 2
        Diagram = drawconfig2(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);

    case 3   % Configuration 3
        Diagram = drawconfig3(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);

    case 4   % Configuration 4
        Diagram = drawconfig4(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);
        
    case 5   % Configuration 5
        Diagram = drawconfig5(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);
    
    case 6   % Configuration 6
        Diagram = drawconfig6(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag);
end
