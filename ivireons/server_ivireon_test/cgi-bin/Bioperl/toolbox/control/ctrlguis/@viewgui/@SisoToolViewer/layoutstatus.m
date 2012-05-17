function layoutstatus(this,varargin)
% LAYOUTSTATUS  positions the status bar and text in the figure window.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2005/12/22 17:44:25 $

FigPos = get(this.Figure,'Position');  % figure position in pixels
% Separator
SepPos = get(this.HG.StatusSeparator(2),'Position');  % in pixels
y = SepPos(2);
s = 1; % 1 pixel wide and high
set(this.HG.StatusSeparator(1),'Position',[s y-1.5*s FigPos(3)-2*s 1.5*s])
set(this.HG.StatusSeparator(2),'Position',[s y FigPos(3)-2*s s])

% Text and real-time update checkbox
CheckPos = get(this.HG.StatusCheckBox,'Position');
CheckPos(1) = FigPos(3)-CheckPos(3);
set(this.HG.StatusCheckBox,'Position',CheckPos)

TextPos = get(this.HG.StatusText,'Position');   % in pixels
TextPos(3) = FigPos(3)-2*TextPos(1)-CheckPos(3);
set(this.HG.StatusText,'Position',TextPos);
