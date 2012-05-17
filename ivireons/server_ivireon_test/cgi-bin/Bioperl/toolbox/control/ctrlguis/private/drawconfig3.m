function Diagram = drawconfig3(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag) 
% ------------------------------------------------------------------------%
% Function: drawconfig3
% Purpose: Draws BlockDiagram for configuration 3
% ------------------------------------------------------------------------%     

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2009/11/09 16:22:33 $

%% adjust axis limits to fill space without changing aspect ratio of diagram
origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
axpos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);

dposw = 501.4250;   dposh = 213.53;
Ar = dposh/dposw;

if SigFlag
    XLim = [0.025,1.175];
    YLim = [-0.175,1.025];
else
    XLim = [0.025,1.175];
    YLim = [0,1];
end
    

[NewXLim,NewYLim] = utAdjustDiagramLimits(XLim,YLim,Ar,axpos(3),axpos(4));

set(AxisHandle,'xlim',NewXLim)
set(AxisHandle,'ylim',NewYLim)



% Define Colors
ColorC = [1 0.45 0.45]; %Feedback Blocks
ColorF = [0 0.85 0]; %FeedForward/Prefilter Blocks
ColorG = [1 1 .8]; % Fixed Blocks


Diagram = struct('B',[], 'L', [], 'S', [], 'Labels', []);


yrow0 = .8;
yrow1 = .6;
boffset = 0.15;
bw = .15; % Block width
bh = .3; % Block height

%% Model and Sum Blocks
Position = [0.25, yrow0];
F = createblock('F',Position, bw, bh, ColorF, AxisHandle);

Position = [.2,yrow1] + [.75*boffset, 0];
Sum1 = createsum('Sum1',Position, AxisHandle);

Position = Sum1.Position + [boffset, 0];
C = createblock('C', Position, bw, bh, ColorC, AxisHandle);

Position = C.Position + [boffset, 0];
Sum2 = createsum('Sum2', Position, AxisHandle);

Position = Sum2.Position + [1.5*boffset, 0];
G = createblock('G', Position, bw, bh, ColorG, AxisHandle);

Position = G.Position + [boffset, 0];
Sum3 = createsum('Sum3', Position, AxisHandle);

yrow2 =.25;
Position = [(C.Position(1)+G.Position(1))/2, yrow2];
H = createblock('H', Position, bw, bh, ColorG, AxisHandle);

Position = H.Position + [-boffset, 0];
Sum4 = createsum('Sum4', Position, AxisHandle);

%% Connector Lines
FSum2 = drawconnectarrow(getpos(F,'R'),getpos(Sum2,'T'), AxisHandle,'xy');
Sum1C = drawconnectarrow(getpos(Sum1,'R'),getpos(C,'L'), AxisHandle);
CSum2 = drawconnectarrow(getpos(C,'R'),getpos(Sum2,'L'), AxisHandle);
Sum2G = drawconnectarrow(getpos(Sum2,'R'),getpos(G,'L'), AxisHandle);
GSum3 = drawconnectarrow(getpos(G,'R'),getpos(Sum3,'L'), AxisHandle);

TempPos = getpos(Sum3,'R') + [boffset/2, 0];
Sum3H = [drawconnectline(getpos(Sum3,'R'),TempPos, AxisHandle); ...
    drawconnectarrow(TempPos,getpos(H,'R'), AxisHandle, 'yx')];

HSum4 = drawconnectarrow(getpos(H,'L'),getpos(Sum4,'R'), AxisHandle);
Sum4Sum1 = drawconnectarrow(getpos(Sum4,'L'),getpos(Sum1,'B'), AxisHandle,'xy');

%% Signals Lines (included in plain)
FLPos =  getpos(F,'L');
rAnchor = [FLPos(1),yrow1]- [.75*boffset,0];
r = [drawconnectarrow(rAnchor, getpos(Sum1,'L'), AxisHandle); ...
    drawconnectarrow(rAnchor+[.5*boffset,0],FLPos,AxisHandle,'yx')];

yAnchor = getpos(Sum3,'R') + [boffset,0];
y = drawconnectarrow(getpos(Sum3,'R'),yAnchor, AxisHandle);



%% Signals and Labels

if SigFlag

    % Signals
    uAnchor = (getpos(Sum2,'R') + getpos(G,'L'))/2;

    duAnchor = getpos(Sum2,'T') + [.25*boffset, 2*boffset];
    TempPos1 = duAnchor -  [0,1.5*boffset];
    TempPos2 = [Sum2.Width*cos(pi/4)/2,Sum2.Height*sin(pi/4)/2] + Sum2.Position;

    du = [drawconnectline(duAnchor, TempPos1, AxisHandle);
        drawconnectarrow(TempPos1, TempPos2, AxisHandle)];

    dyAnchor = getpos(Sum3,'T') + [0, 2*boffset];
    dy = drawconnectarrow(dyAnchor, getpos(Sum3,'T'), AxisHandle);

    nAnchor = getpos(Sum4,'B') - [0, 2*boffset];
    n = drawconnectarrow(nAnchor, getpos(Sum4,'B'), AxisHandle);

    if LabelFlag
        % Feedback Sign
        Sum1Sign = sumsign(Sum1, 'Q3', 1, ConfigData, AxisHandle, EditFlag);

        %Block Labels
%         G = blocklabel(G,'T', ConfigData, AxisHandle, EditFlag);
%         H = blocklabel(H,'B', ConfigData, AxisHandle, EditFlag);
%         C = blocklabel(C,'B', ConfigData, AxisHandle, EditFlag);
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
    Diagram.S = [r;du; dy; n; y];
end

Diagram.B = [F C G H Sum1 Sum2 Sum3 Sum4]';
Diagram.L = {FSum2 Sum1C CSum2 Sum2G GSum3 Sum3H Sum4Sum1}';


% % adjust axis limits to fill space without changing aspect ratio of diagram
% origunits = get(AxisHandle,'units');
% set(AxisHandle,'Units','pixels');
% axpos = get(AxisHandle,'Position');
% set(AxisHandle,'Units',origunits);
% 
% dposw = 501.4250;   dposh = 213.53;
% Ar = dposh/dposw;
% 
% if SigFlag
%     XLim = [0.025,1.175];
%     YLim = [-0.175,1.025];
% else
%     XLim = [0.025,1.175];
%     YLim = [0,1];
% end
%     
% 
% [NewXLim,NewYLim] = utAdjustDiagramLimits(XLim,YLim,Ar,axpos(3),axpos(4));
% 
% set(AxisHandle,'xlim',NewXLim)
% set(AxisHandle,'ylim',NewYLim)


