function rlc_figs()
% Draws a parallel bandpass RLC circuit

%   Author(s): A. DiVergilio
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/06/07 14:35:33 $
type = 'RLC';
figure;
ax = gca;
cla(ax)
set(ax,'XLim',[0 1.85],'YLim',[0.9 1.9],'vis','off');
resistor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
inductor('Parent',ax,'Position',[1.0 1.6],'Size',0.5,'Angle',-90);
capacitor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
wire('Parent',ax,'XData',[0.2 0.3 NaN 0.8 1.6 NaN 1.0 1.4 NaN 1.0 1.4 NaN 1.2 1.2 NaN 1.2 1.2 NaN 0.2 1.6],...
   'YData',[1.7 1.7 NaN 1.7 1.7 NaN 1.6 1.6 NaN 1.1 1.1 NaN 1.7 1.6 NaN 1.1 1.0 NaN 1.0 1.0]);
port('Parent',ax,'XData',[0.2 0.2],'YData',[1.7 1.0],'Name','Vin');
port('Parent',ax,'XData',[1.6 1.6],'YData',[1.7 1.0],'Name','Vout');
text('Parent',ax,'String',type(1),'Position',[0.55 1.555 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(2),'Position',[0.88 1.30 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(3),'Position',[1.30 1.30 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
