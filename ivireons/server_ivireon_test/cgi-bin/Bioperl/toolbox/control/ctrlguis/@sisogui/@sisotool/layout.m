function layout(sisodb)
%LAYOUT  Lays out and resizes SISO Tool front panel

%   Author(s): K. Gondoly, P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2005/11/15 00:53:22 $

% Active editors
isActive = strcmp(get(sisodb.PlotEditors,'Visible'),'on');
ActivePlotEditors = find(isActive);
NumActive = length(ActivePlotEditors);

% Parameters for layout geometry
SISOfig = sisodb.Figure;
FigUnits = get(SISOfig,'Unit');
FigPos = get(SISOfig,'Position');
FigW = FigPos(3);
FigH = FigPos(4);
xBorder = 2.5;  

% Status fame
SF = sisodb.HG.Status;
ySep = 2.5; % y ordinate of separator
SepPos = get(SF.Separator(1),'Position'); x = SepPos(1); h = SepPos(4);
set(SF.Separator(1),'Position',[x ySep-h FigW-2*x h])
SepPos = get(SF.Separator(2),'Position'); x = SepPos(1); h = SepPos(4);
set(SF.Separator(2),'Position',[x ySep FigW-2*x h])

xText = 1.5;
yText = 0.05;
set(SF.StatusText,'Position',[xText yText FigW-2*xText 2])

% Graphical editors
xBorder = 3;
ySpace = FigH-ySep-6;

if NumActive==1 || FigW>120
    hOffset = 8;   % Offset for LHS axis border
    YlabelVis = repmat({'on'},[NumActive 1]);
else    
    % Don't display Y labels if figure is too small
    hOffset = 4;  
    YlabelVis = repmat({'off'},[NumActive 1]);
end
if NumActive<=2 || FigH>40
    vOffset = 5;   % Offset for vertical axis spacing
    SepXlabelVis = 'on'; 
else    
    % Don't display X labels if figure is too small
    vOffset = 3;  
    SepXlabelVis = 'off';
end
AxesW1 = FigW-2*xBorder-hOffset;           % Axes width in single-column config
AxesW2 = (FigW-3*xBorder-2*hOffset)/2;     % Axes width in two-column config
AxesH1 = ySpace;              % Axes height in single-row config
AxesH2 = (ySpace-vOffset)/2;  % Axes height in two-row config
AxesH3 = (ySpace-2*vOffset)/3;  % Axes height in three-row config

% Compute new normalized positions
Xs1 = xBorder+hOffset;
Xs2 = FigW-xBorder-AxesW2;
switch NumActive
    case 1
        XlabelVis = {'on'};
        NewPos = {[Xs1 5.8 AxesW1 AxesH1]};
    case 2
        XlabelVis = {'on';'on'};
        NewPos = {[Xs1 5.8 AxesW2 AxesH1] ; [Xs2 5.8 AxesW2 AxesH1]};
    case 3
        XlabelVis = {SepXlabelVis;'on';'on'};
        NewPos = {[Xs1 5.8+AxesH2+vOffset AxesW2 AxesH2] ; ...
            [Xs1 5.8 AxesW2 AxesH2] ; ...
            [Xs2 5.8 AxesW2 AxesH1]};
        % If Bode Editor is active, make sure it uses the full height
        idx = ActivePlotEditors(LocalFindMultiAxis(sisodb.PlotEditors(ActivePlotEditors)));
        if ~isempty(idx)
            ActivePlotEditors = [ActivePlotEditors(ActivePlotEditors~=idx);idx];
        end
    case 4
        XlabelVis = {SepXlabelVis;'on';SepXlabelVis;'on'};
        NewPos = {[Xs1 5.8+AxesH2+vOffset AxesW2 AxesH2] ; [Xs1 5.8 AxesW2 AxesH2] ;...
            [Xs2 5.8+AxesH2+vOffset AxesW2 AxesH2] ; [Xs2 5.8 AxesW2 AxesH2]};
    case 5
        XlabelVis = {SepXlabelVis;SepXlabelVis;'on';SepXlabelVis;'on'};
        NewPos = {[Xs1 5.8+2*(AxesH3+vOffset) AxesW2 AxesH3]
            [Xs1 5.8+AxesH3+vOffset AxesW2 AxesH3] ; ...
            [Xs1 5.8 AxesW2 AxesH3] ; ...
            [Xs2 5.8+AxesH2+vOffset AxesW2 AxesH2]; ...
            [Xs2 5.8 AxesW2 AxesH2]};
        % If Bode Editor is active, make sure it uses the larger height
        idx = ActivePlotEditors(LocalFindMultiAxis(sisodb.PlotEditors(ActivePlotEditors)));
        if ~isempty(idx)
            ActivePlotEditors = [ActivePlotEditors(ActivePlotEditors~=idx);idx];
        end
    case 6
        XlabelVis = {SepXlabelVis;SepXlabelVis;'on';SepXlabelVis;SepXlabelVis;'on'};
        NewPos = {[Xs1 5.8+2*(AxesH3+vOffset) AxesW2 AxesH3]
            [Xs1 5.8+AxesH3+vOffset AxesW2 AxesH3] ; ...
            [Xs1 5.8 AxesW2 AxesH3] ; ...
            [Xs2 5.8+2*(AxesH3+vOffset) AxesW2 AxesH3]; ...
            [Xs2 5.8+AxesH3+vOffset AxesW2 AxesH3]; ...
            [Xs2 5.8 AxesW2 AxesH3]};

end


% Reset positions of active editors and adjust label visibility
% RE: axes position is expected in normalized units!
for ct=1:NumActive,
    Editor = sisodb.PlotEditors(ActivePlotEditors(ct));
    % New position
    Editor.Axes.Position = NewPos{ct}./[FigW FigH FigW FigH];
    % Label visibility
    Editor.xylabelvis(XlabelVis{ct},YlabelVis{ct})
end


%----------------------- Local functions ----------------------------------

function idx = LocalFindMultiAxis(ActiveEditors)

idx = [];
for ct=1:length(ActiveEditors)
    if length(getaxes(ActiveEditors(ct).Axes))>1
       idx = ct; break;
    end
end

