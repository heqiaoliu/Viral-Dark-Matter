function applyPlotOpts(this,h)
%APPLYPLOTOPTS  set plot properties

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:47 $

AxGrid = h.AxesGrid;

%% Apply Title settings
AxGrid.Title = this.Title.String;
TitleStyle = AxGrid.TitleStyle;
TitleStyle.FontSize = this.Title.FontSize;
TitleStyle.FontWeight = this.Title.FontWeight';
TitleStyle.FontAngle = this.Title.FontAngle;
TitleStyle.Color = this.Title.Color;
TitleStyle.Interpreter = this.Title.Interpreter;

%% Apply XLabel settings
AxGrid.XLabel = this.XLabel.String;             
XLabelStyle = AxGrid.XLabelStyle;
XLabelStyle.FontSize = this.XLabel.FontSize;
XLabelStyle.FontWeight = this.XLabel.FontWeight';
XLabelStyle.FontAngle = this.XLabel.FontAngle;
XLabelStyle.Color = this.XLabel.Color;
XLabelStyle.Interpreter = this.XLabel.Interpreter;

%% Apply YLabel settings
AxGrid.YLabel = this.YLabel.String;             
YLabelStyle = AxGrid.YLabelStyle;
YLabelStyle.FontSize = this.YLabel.FontSize;
YLabelStyle.FontWeight = this.YLabel.FontWeight';
YLabelStyle.FontAngle = this.YLabel.FontAngle;
YLabelStyle.Color = this.YLabel.Color;
YLabelStyle.Interpreter = this.YLabel.Interpreter;
      
%% Apply TickLabel settings
TickLabelStyle = AxGrid.AxesStyle;
TickLabelStyle.FontSize = this.TickLabel.FontSize;
TickLabelStyle.FontWeight = this.TickLabel.FontWeight';
TickLabelStyle.FontAngle = this.TickLabel.FontAngle;
TickLabelStyle.XColor = this.TickLabel.Color;
TickLabelStyle.YColor = this.TickLabel.Color;
      
%% Apply Grid settings                 
AxGrid.Grid = this.Grid;

%% Apply XLimMode settings
if all(size(AxGrid.XLimMode) == size(this.XLimMode))
    AxGrid.XLimMode = this.XLimMode;
else
    if length(this.XLimMode) == 1
        AxGrid.XLimMode(:) = this.XLimMode;
    else
        ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','XLimMode')
    end
end 

% Apply XLim settings
ax = AxGrid.getaxes('2d');  
CurrentXLim = get(ax(1,:),{'Xlim'});

if all(size(CurrentXLim) == size(this.XLim))
    CurrentXLim  = this.XLim;
else
    if length(this.XLim) == 1
        CurrentXLim(:) = this.XLim;
    else
        ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','XLim')
    end
end 

% Apply Limits only to axes that are set to manual
manboo = strcmpi('Manual',AxGrid.XLimMode);
for ct = 1:length(manboo);
    if manboo(ct)
        set(ax(:,ct),'XLim',CurrentXLim{ct})
    end
end

%% Apply YLimMode settings
if all(size(AxGrid.YLimMode) == size(this.YLimMode))
    AxGrid.YLimMode = this.YLimMode;
else 
    if length(this.YLimMode) == 1
        AxGrid.YLimMode(:) = this.YLimMode;
    else
        ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','YLimMode')
    end
end 

% Apply YLim settings
ax = AxGrid.getaxes('2d');  
CurrentYLim = get(ax(:,1),{'Ylim'});

if all(size(CurrentYLim) == size(this.YLim))
    CurrentYLim  = this.YLim;
else
   if length(this.XLim) == 1
        CurrentYLim(:) = this.YLim;
   else
       ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','YLim')
    end
end 

% Apply Limits only to axes that are set to manual
manboo = strcmpi('Manual',AxGrid.YLimMode);
for ct = 1:length(manboo);
    if manboo(ct)
        set(ax(ct,:),'YLim',CurrentYLim{ct})
    end
end