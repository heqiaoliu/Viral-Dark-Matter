function Diagram = drawconfig2(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag) 
% ------------------------------------------------------------------------%
% Function: drawconfig2
% Purpose: Draws BlockDiagram for configuration 2
% ------------------------------------------------------------------------%     

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2009/11/09 16:22:32 $

%% adjust axis limits to fill space without changing aspect ratio of diagram
origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
axpos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);


dposw = 501.4250;   dposh = 213.53;
Ar = dposh/dposw;

if SigFlag
    XLim = [-.05,1.2];
    YLim = [-.10,1.1];
else
    XLim = [-0.05,1.2];
    YLim = [0.05,.95];
end
    
[NewXLim,NewYLim] = utAdjustDiagramLimits(XLim,YLim,Ar,axpos(3),axpos(4));

set(AxisHandle,'xlim',NewXLim)
set(AxisHandle,'ylim',NewYLim)



% Define Colors
ColorC = [1 0.45 0.45]; %Feedback Blocks
ColorF = [0 0.85 0]; %FeedForward/Prefilter Blocks
ColorG = [1 1 .8]; % Fixed Blocks


Diagram = struct('B',[], 'L', [], 'S', [], 'Labels', []);



yrow1 = .75;
yrow2 = .25;
boffset = 0.15;
bw = .15; % Block width
bh = .3; % Block height

%% Model and Sum Blocks
Position = [0.2, yrow1];
F = createblock('F',Position, bw, bh, ColorF, AxisHandle);

Position = F.Position + [boffset, 0];
Sum1 = createsum('Sum1',Position, AxisHandle);

Position = [Sum1.Position(1),yrow2] + [boffset, 0];
C = createblock('C', Position, bw, bh, ColorC, AxisHandle);

Position = C.Position + [1.5*boffset, 0];
Sum3 = createsum('Sum3', Position, AxisHandle);

Position = Sum3.Position + [boffset, 0];
H = createblock('H', Position, bw, bh, ColorG, AxisHandle);

Position = [(H.Position(1)+C.Position(1))/2, yrow1];
G = createblock('G', Position, bw, bh, ColorG, AxisHandle);

Position = G.Position + [1.5*boffset, 0];
Sum2 = createsum('Sum2', Position, AxisHandle);



%% Connector Lines
FSum1 = drawconnectarrow(getpos(F,'R'),getpos(Sum1,'L'), AxisHandle);
Sum1G = drawconnectarrow(getpos(Sum1,'R'),getpos(G,'L'), AxisHandle);
GSum2 = drawconnectarrow(getpos(G,'R'),getpos(Sum2,'L'), AxisHandle);

HRPos = getpos(H,'R');
TempPos = [HRPos(1),yrow1] + [boffset/2, 0];
Sum2H = [drawconnectline(getpos(Sum2,'R'),TempPos, AxisHandle); ...
    drawconnectarrow(TempPos,getpos(H,'R'), AxisHandle, 'yx')];

HSum3 = drawconnectarrow(getpos(H,'L'),getpos(Sum3,'R'), AxisHandle);
Sum3C = drawconnectarrow(getpos(Sum3,'L'),getpos(C,'R'), AxisHandle);
CSum1 = drawconnectarrow(getpos(C,'L'),getpos(Sum1,'B'), AxisHandle,'xy');

% Signals Lines (included in plain)
rAnchor = getpos(F,'L') - [.75*boffset,0];
r = drawconnectarrow(rAnchor, getpos(F,'L'), AxisHandle);

yAnchor = getpos(Sum2,'R') + [1.5*boffset,0];
y = drawconnectarrow(getpos(Sum2,'R'),yAnchor, AxisHandle);



%% Signals and Labels
if SigFlag

    % Signals
    uAnchor = (getpos(Sum1,'R') + getpos(G,'L'))/2;

    duAnchor = getpos(Sum1,'T') + [0, 1.5*boffset];
    du = drawconnectarrow(duAnchor, getpos(Sum1,'T'), AxisHandle);

    dyAnchor = getpos(Sum2,'T') + [0, 1.5*boffset];
    dy = drawconnectarrow(dyAnchor, getpos(Sum2,'T'), AxisHandle);

    nAnchor = getpos(Sum3,'B') - [0, 1.5*boffset];
    n = drawconnectarrow(nAnchor, getpos(Sum3,'B'), AxisHandle);

    if LabelFlag
        % Feedback Sign
        Sum1Sign = sumsign(Sum1, 'Q3', 1, ConfigData, AxisHandle, EditFlag);

%         %Block Labels
%         G = blocklabel(G,'T', ConfigData, AxisHandle, EditFlag);
%         H = blocklabel(H,'T', ConfigData, AxisHandle, EditFlag);
%         C = blocklabel(C,'T', ConfigData, AxisHandle, EditFlag);
%         F = blocklabel(F,'T', ConfigData, AxisHandle, EditFlag);

        % Input Labels (r,dy,du,n)
        SigType = 'Input';
        rLabel = signallabel(rAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
        dyLabel = signallabel(dyAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
        duLabel = signallabel(duAnchor, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);
        nLabel = signallabel(nAnchor, 'B', SigType, 4, ConfigData, AxisHandle, EditFlag);

        % Output Labels (y,u)
        SigType = 'Output';
        yLabel = signallabel(yAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
        uLabel = signallabel(uAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);

        Diagram.Labels = {rLabel,dyLabel,duLabel,nLabel,yLabel,uLabel};
    end
    Diagram.S = [r, du, dy, n, y];
end

Diagram.B = [F C G H Sum1 Sum2 Sum3]';
Diagram.L = {FSum1 Sum1G GSum2 Sum2H HSum3 Sum3C CSum1}';






