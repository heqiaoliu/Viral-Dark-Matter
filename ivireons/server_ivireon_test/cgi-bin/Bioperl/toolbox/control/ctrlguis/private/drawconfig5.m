function Diagram = drawconfig5(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag) 
% ------------------------------------------------------------------------%
% Function: drawconfig5
% Purpose: Draws BlockDiagram for configuration 5
% ------------------------------------------------------------------------%     

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:03:40 $

%% adjust axis limits to fill space without changing aspect ratio of diagram
origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
axpos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);

% dposw = 434;   dposh = 342.3;
dposw = 900;   dposh = 500;
Ar = dposh/dposw;

if SigFlag
    XLim = [-.05,1.35];
    YLim = [-.05,1.35];
else
%     XLim = [-.05,1];
%     YLim = [-.05,1];
    XLim = [.05,1.35];
    YLim = [0,1.25];

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
boffset = 0.13;
bw = .15; % block width
bh = .25; % block height



%% Model and Sum Blocks
Position = [0.2, yrow1];
F = createblock('F',Position, bw, bh, ColorF, AxisHandle);

Position = F.Position + [1.1*boffset, 0];
Sum1 = createsum('Sum1', Position, AxisHandle);

Position = Sum1.Position + [1.25*boffset, 0];
C = createblock('C', Position, bw, bh, ColorC, AxisHandle);

Position = C.Position + [1.25*boffset, 0];
Sum2 = createsum('Sum2', Position, AxisHandle);

Position = Sum2.Position + [1.5*boffset, 0];
G1 = createblock('G1', Position, bw, bh, ColorG, AxisHandle);

Position = G1.Position + [1.25*boffset, 0];
Sum3 = createsum('Sum3', Position, AxisHandle);

Position = Sum3.Position + [0,2*boffset];
Gd = createblock('Gd', Position, bw,bh, ColorG, AxisHandle);

Position = getpos(Sum3,'R') + [boffset/2,0] - [0,2.25*boffset];
Sum4 = createsum('Sum4', Position, AxisHandle);

Position = getpos(Sum4,'L') - [1.5*boffset,0];
G2 = createblock('G2', Position, bw,bh, ColorG, AxisHandle);

%% Signals
rAnchor = getpos(F,'L') - [boffset,0];
r = struct(...
    'Signal', drawconnectarrow(rAnchor, getpos(F,'L'), AxisHandle),...
    'Block', 'F',...
    'Label', []);

yAnchor = getpos(Sum3,'R') + [boffset,0];
y = struct(...
    'Signal', drawconnectarrow(getpos(Sum3,'R'),yAnchor, AxisHandle),...
    'Block', 'Sum3',...
    'Label', []);

uAnchor = (getpos(Sum2,'R') + getpos(G1,'L'))/2;
%% Connector Lines
FSum1 = drawconnectarrow(getpos(F,'R'),getpos(Sum1,'L'), AxisHandle);

Sum1C = drawconnectarrow(getpos(Sum1,'R'),getpos(C,'L'), AxisHandle);

CSum2 = drawconnectarrow(getpos(C,'R'),getpos(Sum2,'L'), AxisHandle);

Sum2G1 = drawconnectarrow(getpos(Sum2,'R'),getpos(G1,'L'), AxisHandle);

G1Sum3 = drawconnectarrow(getpos(G1,'R'),getpos(Sum3,'L'), AxisHandle);

TempPos = getpos(Sum3,'R') + [boffset/2, 0];
TempPosSum4 = drawconnectarrow(TempPos,getpos(Sum4,'T'), AxisHandle);

TempPos = (getpos(C,'R') + getpos(Sum2,'L'))/2+[-.01,0];
TempPosG2 = drawconnectarrow(TempPos,getpos(G2,'L'), AxisHandle, 'yx');

G2Sum4 = drawconnectarrow(getpos(G2,'R'),getpos(Sum4,'L'), AxisHandle);

%     drawconnectline(dtAnchor,temppos1, AxisHandle);
%     drawconnectline(temppos1,temppos2, AxisHandle);
%     drawconnectarrow(temppos2,getpos(Sum4,'B'),AxisHandle);


GdSum3 = drawconnectarrow(getpos(Gd,'B'),getpos(Sum3,'T'), AxisHandle);

TempPos = getpos(Sum4,'B') - [0,2.25*boffset] - [1.5*boffset,0];
dtAnchor = TempPos;
Sum4TempPos = drawconnectline(getpos(Sum4,'B'),TempPos,AxisHandle,'yx');
TempPosSum1 = drawconnectarrow(TempPos,getpos(Sum1,'B'),AxisHandle,'xy');

dyAnchor = getpos(Gd,'L') + [-boffset,0];
dy = struct(...
    'Signal',drawconnectarrow(dyAnchor, getpos(Gd,'L'), AxisHandle),...
    'Block', 'Sum3',...
    'Label',[]);


%% Signals and labels
if SigFlag 

    % Signals
    duAnchor = getpos(Sum2,'T') + [0, boffset];
    du = struct(...
        'Signal',drawconnectarrow(duAnchor, getpos(Sum2,'T'), AxisHandle),...
        'Block', 'Sum2',...
        'Label',[]);



%     nAnchor = getpos(Sum4,'B') - [0, boffset];
%     n = struct(...
%         'Signal',drawconnectarrow(nAnchor, getpos(Sum4,'B'), AxisHandle),...
%         'Block', 'Sum4', ...
%         'Label',[]);
             
        if LabelFlag 
            % Feedback Sign UIcontrols
             Sum1Sign = sumsign(Sum1, 'Q3', 1, ConfigData, AxisHandle, EditFlag);
             Sum2Sign = sumsign(Sum4, 'Q3','-', ConfigData, AxisHandle, EditFlag);
%             Sum3Sign = sumsign(Sum2, 'Q3', 2, ConfigData, AxisHandle, EditFlag);
%             Sum4Sign = sumsign(Sum2, 'Q3', 2, ConfigData, AxisHandle, EditFlag);
            %Block Labels
%             G = blocklabel(G,'T', ConfigData, AxisHandle, EditFlag);
%             C1 = blocklabel(C1,'T', ConfigData, AxisHandle, EditFlag);
%             C2 = blocklabel(C2,'R', ConfigData, AxisHandle, EditFlag);
%             H = blocklabel(H,'T', ConfigData, AxisHandle, EditFlag);

            % Input Labels (r,dy,du,n)
            SigType = 'Input';
            rLabel = signallabel(rAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            dyLabel = signallabel(dyAnchor, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);
            duLabel = signallabel(duAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
            

            % Output Labels (y,u)
            SigType = 'Output';
            yLabel = signallabel(yAnchor, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            uLabel = signallabel(uAnchor, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
            dtLabel = signallabel(dtAnchor, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);

            Diagram.Labels = {rLabel,dyLabel,duLabel,yLabel,uLabel,dtLabel};
        end
    Diagram.S = [r, du, dy, y];
end

%  Order and Group for Blocks and Lines
Diagram.B = [F C G1 G2 Gd Sum1 Sum2 Sum3 Sum4]';
Diagram.L = {FSum1 Sum1C CSum2 Sum2G1 G1Sum3 TempPosSum4 TempPosG2 G2Sum4 GdSum3 Sum4TempPos TempPosSum1}';
