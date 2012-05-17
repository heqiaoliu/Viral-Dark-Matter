function Diagram = drawconfig4(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag) 
% ------------------------------------------------------------------------%
% Function: drawconfig4
% Purpose: Draws BlockDiagram for configuration 4
% ------------------------------------------------------------------------%     

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2006/01/26 01:48:17 $

%% adjust axis limits to fill space without changing aspect ratio of diagram
origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
axpos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);

dposw = 501.4250;   dposh = 213.53;
Ar = dposh/dposw;

if SigFlag
    XLim = [0,1.05];
    YLim = [-0.175,1.025];
else
    XLim = [0,1.05];
    YLim = [0,1];
end
    

[NewXLim,NewYLim] = utAdjustDiagramLimits(XLim,YLim,Ar,axpos(3),axpos(4));

set(AxisHandle,'xlim',NewXLim)
set(AxisHandle,'ylim',NewYLim)



%% Define Colors
ColorC = [1 0.45 0.45]; %Feedback Blocks
ColorF = [0 0.85 0]; %FeedForward/Prefilter Blocks
ColorG = [1 1 .8]; % Fixed Blocks


Diagram = struct('B',[], 'L', [], 'S', [], 'Labels', []);

yrow1 = 0.75;
boffset = 0.15;
bw = .15; % block width
bh = .25; % block height

%% Model and Sum Blocks
Position = [0.2, yrow1];
Sum1 = createsum('Sum1',Position, AxisHandle);

Position = Sum1.Position + [boffset, 0];
C1 = createblock('C1', Position, bw, bh, ColorC, AxisHandle);

Position = C1.Position + [boffset, 0];
Sum2 = createsum('Sum2', Position, AxisHandle);

Position = Sum2.Position + [1.25*boffset, 0];
G = createblock('G', Position, bw, bh, ColorG, AxisHandle);

Position = G.Position + [boffset, 0];
Sum3 = createsum('Sum3', Position, AxisHandle);

Position = Sum2.Position + [0,-2.25*boffset];
C2 = createblock('C2', Position, bw, bh, ColorC, AxisHandle);

Position = C2.Position + [boffset, -2.25*boffset];
Sum4 = createsum('Sum4', Position, AxisHandle);

Position = Sum4.Position + [boffset, 0];
H = createblock('H', Position, bw, bh, ColorG, AxisHandle);


%% Signals
rAnchor = getpos(Sum1,'L') - [boffset,0];
r = struct(...
    'Signal', drawconnectarrow(rAnchor, getpos(Sum1,'L'), AxisHandle),...
    'Block', 'Sum1',...
    'Label', []);

yAnchor = getpos(Sum3,'R') + [boffset,0];
y = struct(...
    'Signal', drawconnectarrow(getpos(Sum3,'R'),yAnchor, AxisHandle),...
    'Block', 'G',...
    'Label', []);

uAnchor = (getpos(Sum2,'R') + getpos(G,'L'))/2;

%% Connector Lines
Sum1C1 = drawconnectarrow(getpos(Sum1,'R'),getpos(C1,'L'), AxisHandle);

C1Sum2 = drawconnectarrow(getpos(C1,'R'),getpos(Sum2,'L'), AxisHandle);

Sum2G = drawconnectarrow(getpos(Sum2,'R'),getpos(G,'L'), AxisHandle);

GSum3 = drawconnectarrow(getpos(G,'R'),getpos(Sum3,'L'), AxisHandle);

TempPos = getpos(Sum3,'R') + [boffset/2, 0];
Sum3H = [drawconnectline(getpos(Sum3,'R'),TempPos, AxisHandle); ...
    drawconnectarrow(TempPos,getpos(H,'R'), AxisHandle, 'yx')];

HSum4 = drawconnectarrow(getpos(H,'L'),getpos(Sum4,'R'), AxisHandle);

Sum4C2 = drawconnectarrow(getpos(Sum4,'L'),getpos(C2,'B'), AxisHandle, 'xy');

Sum4Sum1 = drawconnectarrow(getpos(Sum4,'L'),getpos(Sum1,'B'), AxisHandle,'xy');

C2Sum2 = drawconnectarrow(getpos(C2,'T'),getpos(Sum2,'B'), AxisHandle);

%% Signals and labels
if SigFlag

    % Signals
    duAnchor = getpos(Sum2,'T') + [0, boffset];
    du = struct(...
        'Signal',drawconnectarrow(duAnchor, getpos(Sum2,'T'), AxisHandle),...
        'Block', 'Sum2',...
        'Label',[]);

    dyAnchor = getpos(Sum3,'T') + [0, boffset];
    dy = struct(...
        'Signal',drawconnectarrow(dyAnchor, getpos(Sum3,'T'), AxisHandle),...
        'Block', 'Sum3',...
        'Label',[]);

    nAnchor = getpos(Sum4,'B') - [0, boffset];
    n = struct(...
        'Signal',drawconnectarrow(nAnchor, getpos(Sum4,'B'), AxisHandle),...
        'Block', 'Sum4', ...
        'Label',[]);
    
        
        if LabelFlag
            % Feedback Sign UIcontrols
            Sum1Sign = sumsign(Sum1, 'Q3', 1, ConfigData, AxisHandle, EditFlag);
            Sum2Sign = sumsign(Sum2, 'Q3', 2, ConfigData, AxisHandle, EditFlag);

            %Block Labels
%             G = blocklabel(G,'T', ConfigData, AxisHandle, EditFlag);
%             C1 = blocklabel(C1,'T', ConfigData, AxisHandle, EditFlag);
%             C2 = blocklabel(C2,'R', ConfigData, AxisHandle, EditFlag);
%             H = blocklabel(H,'T', ConfigData, AxisHandle, EditFlag);

            % Input Labels (r,dy,du,n)
            SigType = 'Input';
            rLabel = signallabel(rAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            dyLabel = signallabel(dyAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
            duLabel = signallabel(duAnchor, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);
            nLabel = signallabel(nAnchor, 'L', SigType, 4, ConfigData, AxisHandle, EditFlag);

            % Output Labels (y,u)
            SigType = 'Output';
            yLabel = signallabel(yAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            uLabel = signallabel(uAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);

            Diagram.Labels = {rLabel,dyLabel,duLabel,nLabel,yLabel,uLabel};
        end
    Diagram.S = [r, du, dy, n, y];
end

%  Order and Group for Blocks and Lines
Diagram.B = [C1; C2; G; H; Sum1; Sum2; Sum3; Sum4];
Diagram.L = {Sum1C1 C1Sum2 Sum2G GSum3 Sum3H HSum4 Sum4C2 Sum4Sum1 C2Sum2}';
