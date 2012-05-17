function applyRespPlotOpts(this,h,varargin)
%APPLYRESPPLOTOPTS  set respplot properties

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:56 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

% Apply IO Grouping settings
h.IOGrouping = this.IOGrouping;

% Apply Column Label Style settings
InputLabelStyle = h.AxesGrid.ColumnLabelStyle;
InputLabelStyle.FontSize = this.InputLabels.FontSize;
InputLabelStyle.FontWeight = this.InputLabels.FontWeight';
InputLabelStyle.FontAngle = this.InputLabels.FontAngle;
InputLabelStyle.Color = this.InputLabels.Color;
InputLabelStyle.Interpreter = this.InputLabels.Interpreter;

% Apply Row Label Style settings
OutputLabelStyle = h.AxesGrid.RowLabelStyle;
OutputLabelStyle.FontSize = this.OutputLabels.FontSize;
OutputLabelStyle.FontWeight = this.OutputLabels.FontWeight';
OutputLabelStyle.FontAngle = this.OutputLabels.FontAngle;
OutputLabelStyle.Color = this.OutputLabels.Color;
OutputLabelStyle.Interpreter = this.OutputLabels.Interpreter;

% Apply IO Visiiblity settings
if all(size(h.InputVisible) == size(this.InputVisible)) 
    h.InputVisible = this.InputVisible;
else
    if length(this.InputVisible) == 1
        h.InputVisible(:) = this.InputVisible;
    else
        ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','InputVisible')
    end
end

if all(size(h.OutputVisible) == size(this.OutputVisible))
    h.OutputVisible = this.OutputVisible;
else
    if length(this.OutputVisible) == 1
        numi = length(h.OutputVisible);
        h.OutputVisible(:) = this.OutputVisible;
    else
        ctrlMsgUtils.warning('Controllib:plots:SetOptionsIncorrectSize','OutputVisible')
    end
end


% Call superclass method if allflag is true
if allflag
   applyPlotOpts(this,h);
end


      

             
