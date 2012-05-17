function getRespPlotOpts(this,h,varargin)
%GETRESPPLOTOPTS Gets plot options of @respplot h  

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:57 $

if isempty(varargin)
    allflag = false;
else
    allflag = varargin{1};
end

% IO Grouping
this.IOGrouping = h.IOGrouping;
      
% Input Labels
InputLabelStyle = h.AxesGrid.ColumnLabelStyle;
this.InputLabels = struct('FontSize',   InputLabelStyle.FontSize, ...
                       'FontWeight', InputLabelStyle.FontWeight, ...
                       'FontAngle',  InputLabelStyle.FontAngle, ...
                       'Color',      InputLabelStyle.Color);

% Output Labels
OutputLabelStyle = h.AxesGrid.RowLabelStyle;
this.OutputLabels = struct('FontSize',   OutputLabelStyle.FontSize, ...
                        'FontWeight', OutputLabelStyle.FontWeight, ...
                        'FontAngle',  OutputLabelStyle.FontAngle, ...
                        'Color',      OutputLabelStyle.Color);                    

% IO visibility
this.InputVisible = h.InputVisible;
this.OutputVisible = h.OutputVisible;
         
                 
if allflag
    getPlotOpts(this,h);
end
    
  
