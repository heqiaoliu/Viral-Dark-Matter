function Diagram = drawconfig6(ConfigData, AxisHandle, SigFlag, LabelFlag, EditFlag) 
% ------------------------------------------------------------------------%
% Function: drawconfig6
% Purpose: Draws BlockDiagram for configuration 6
% ------------------------------------------------------------------------%     

%   Author(s): C. Buhr 
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:03:41 $

%% adjust axis limits to fill space without changing aspect ratio of diagram
origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
axpos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);



% dposw = 400; dposh = 210;
dposw = 400; dposh = 210;
Ar = dposh/dposw;

if SigFlag
    XLim = [-.05,1.85];
    YLim = [-0.05,1];
else
%     XLim = [-5.05,1];
%     YLim = [-.25,0.8];
    XLim = [.05,1.7];
    YLim = [-0.2,1.1];

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

Position = F.Position + [1.25*boffset, 0];
Sum1 = createsum('Sum1', Position, AxisHandle);

Position = Sum1.Position + [boffset, 0];
C1 = createblock('C1', Position, bw, bh, ColorC, AxisHandle);

Position = C1.Position + [1.25*boffset, 0];
Sum2 = createsum('Sum2', Position, AxisHandle);

Position = Sum2.Position + [boffset, 0];
C2 = createblock('C2', Position, bw, bh, ColorC, AxisHandle);

Position = C2.Position + [boffset, 0];
Sum3 = createsum('Sum3', Position, AxisHandle);

Position = Sum3.Position + [1.5*boffset, 0];
G1 = createblock('G1', Position, bw, bh, ColorG, AxisHandle);

Position = G1.Position + [1.5*boffset, 0];
Sum4 = createsum('Sum4', Position, AxisHandle);

Position = Sum4.Position + [1.5*boffset, 0];
G2 = createblock('G2', Position, bw, bh, ColorG, AxisHandle);

Position = G2.Position + [boffset, 0];
Sum5 = createsum('Sum5', Position, AxisHandle);


Position = G1.Position - [0,2.25*boffset];
H1 = createblock('H1', Position, bw, bh, ColorG, AxisHandle);

Position = getpos(H1,'L') - [boffset/2,0];
Sum6 = createsum('Sum6', Position, AxisHandle);

Position = G2.Position - [0,4.5*boffset];
H2 = createblock('H2', Position, bw, bh, ColorG, AxisHandle);

Position = getpos(H2,'L') - [boffset/2,0];
Sum7 = createsum('Sum7', Position, AxisHandle);

%% Signals
rAnchor1 = getpos(F,'L') - [boffset,0];
r1 = struct(...
    'Signal', drawconnectarrow(rAnchor1, getpos(F,'L'), AxisHandle),...
    'Block', 'F',...
    'Label', []);

rAnchor2 = getpos(C1,'R') + [boffset/2,0];
r2 = struct(...
    'Signal', [],...
    'Block', 'Sum2',...
    'Label', []);

yAnchor1 = getpos(Sum5,'R') + [boffset,0];
y1 = struct(...
    'Signal', drawconnectarrow(getpos(Sum5,'R'),yAnchor1, AxisHandle),...
    'Block', 'Sum5',...
    'Label', []);

yAnchor2 = getpos(G1,'R') + [boffset/2,0];
y2 = struct(...
    'Signal', [],...
    'Block', 'G1',...
    'Label', []);


uAnchor1 = (getpos(Sum3,'R') + getpos(G1,'L'))/2;
u1 = struct(...
    'Signal', [],...
    'Block', 'Sum3',...
    'Label', []);
uAnchor2 = (getpos(Sum4,'R') + getpos(G2,'L'))/2;
u2 = struct(...
    'Signal', [],...
    'Block', 'Sum4',...
    'Label', []);
%% Connector Lines
FSum1 = drawconnectarrow(getpos(F,'R'),getpos(Sum1,'L'), AxisHandle);

Sum1C1 = drawconnectarrow(getpos(Sum1,'R'),getpos(C1,'L'), AxisHandle);

C1Sum2 = drawconnectarrow(getpos(C1,'R'),getpos(Sum2,'L'), AxisHandle);

Sum2C2 = drawconnectarrow(getpos(Sum2,'R'),getpos(C2,'L'), AxisHandle);

C2Sum3 = drawconnectarrow(getpos(C2,'R'),getpos(Sum3,'L'), AxisHandle);

Sum3G1 = drawconnectarrow(getpos(Sum3,'R'),getpos(G1,'L'), AxisHandle);

G1Sum4 = drawconnectarrow(getpos(G1,'R'),getpos(Sum4,'L'), AxisHandle);

Sum4G2 = drawconnectarrow(getpos(Sum4,'R'),getpos(G2,'L'), AxisHandle);

G2Sum5 = drawconnectarrow(getpos(G2,'R'),getpos(Sum5,'L'), AxisHandle);

TempPos = (getpos(Sum5,'R') + yAnchor1)/2;
% TempPosH2 = drawconnectarrow(TempPos,getpos(H2,'R'), AxisHandle, 'yx');

Sum5H2 = [drawconnectline(getpos(Sum5,'R'),TempPos, AxisHandle); ...
    drawconnectarrow(TempPos,getpos(H2,'R'), AxisHandle, 'yx')];


H2Sum7 = drawconnectarrow(getpos(H2,'L'),getpos(Sum7,'R'), AxisHandle);

Sum7Sum1 = drawconnectarrow(getpos(Sum7,'L'),getpos(Sum1,'B'), AxisHandle,'xy');

TempPos = (getpos(Sum4,'L') + getpos(G1,'R'))/2;
% TempPosH1 = drawconnectarrow(TempPos,getpos(H1,'R'), AxisHandle, 'yx');
G1H1 = [drawconnectline(getpos(G1,'R'),TempPos, AxisHandle); ...
    drawconnectarrow(TempPos,getpos(H1,'R'), AxisHandle, 'yx')];

H1Sum6 = drawconnectarrow(getpos(H1,'L'),getpos(Sum6,'R'), AxisHandle);

Sum6Sum2 = drawconnectarrow(getpos(Sum6,'L'),getpos(Sum2,'B'), AxisHandle,'xy');


%% Signals and labels
if SigFlag 

    % Signals
    duAnchor1 = getpos(Sum3,'T') + [0, boffset];
    du1 = struct(...
        'Signal',drawconnectarrow(duAnchor1, getpos(Sum3,'T'), AxisHandle),...
        'Block', 'Sum3',...
        'Label',[]);
    
    duAnchor2 = getpos(Sum4,'T') + [0, boffset];
    du2 = struct(...
        'Signal',drawconnectarrow(duAnchor2, getpos(Sum4,'T'), AxisHandle),...
        'Block', 'Sum4',...
        'Label',[]);
    
    dyAnchor = getpos(Sum5,'T') + [0, boffset];
    dy = struct(...
        'Signal',drawconnectarrow(dyAnchor, getpos(Sum5,'T'), AxisHandle),...
        'Block', 'Sum5',...
        'Label',[]);

    nAnchor1 = getpos(Sum6,'B') - [0, boffset];
    n1 = struct(...
        'Signal',drawconnectarrow(nAnchor1, getpos(Sum6,'B'), AxisHandle),...
        'Block', 'Sum6', ...
        'Label',[]);
    
    nAnchor2 = getpos(Sum7,'B') - [0, boffset];
    n2 = struct(...
        'Signal',drawconnectarrow(nAnchor2, getpos(Sum7,'B'), AxisHandle),...
        'Block', 'Sum7', ...
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
            rLabel1 = signallabel(rAnchor1, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            duLabel1 = signallabel(duAnchor1, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
            duLabel2 = signallabel(duAnchor2, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);
            dyLabel = signallabel(dyAnchor, 'T', SigType, 4, ConfigData, AxisHandle, EditFlag);
            nLabel1 = signallabel(nAnchor1, 'L', SigType, 5, ConfigData, AxisHandle, EditFlag);
            nLabel2 = signallabel(nAnchor2, 'L', SigType, 6, ConfigData, AxisHandle, EditFlag);

            % Output Labels (y,u)
            SigType = 'Output';
            uLabel1 = signallabel(uAnchor1, 'T', SigType, 1, ConfigData, AxisHandle, EditFlag);
            yLabel2 = signallabel(yAnchor2, 'T', SigType, 2, ConfigData, AxisHandle, EditFlag);
            uLabel2 = signallabel(uAnchor2, 'T', SigType, 3, ConfigData, AxisHandle, EditFlag);
            yLabel1 = signallabel(yAnchor1, 'T', SigType, 4, ConfigData, AxisHandle, EditFlag);

            


            Diagram.Labels = {rLabel1,dyLabel,duLabel1,duLabel2,nLabel1,nLabel2,yLabel1,yLabel2,uLabel1,uLabel2};
        end
    Diagram.S = [r1,r2,dy,du1,du2,n1,n2,y1,y2,u1,u2];
end

%  Order and Group for Blocks and Lines
Diagram.B = [C1 C2 F G1 G2 H1 H2 Sum1 Sum2 Sum3 Sum4 Sum5 Sum6 Sum7]';
Diagram.L = {FSum1 Sum1C1 C1Sum2 Sum2C2 C2Sum3 Sum3G1 G1Sum4 Sum4G2 G2Sum5 Sum5H2 H2Sum7 Sum7Sum1 G1H1 H1Sum6 Sum6Sum2}';
