function layoutstatus(this,varargin)
% LAYOUTSTATUS  positions the status bar and text in the figure window.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/12/22 17:44:43 $

FigPos = get(this.Figure,'Position');  % figure position in pixels
% Separator
SepPos = get(this.HG.StatusSeparator(2),'Position');  % in pixels
y = SepPos(2);
s = 1; % 1 pixel wide and high
set(this.HG.StatusSeparator(1),'Position',[s y-1.5*s FigPos(3)-2*s 1.5*s])
set(this.HG.StatusSeparator(2),'Position',[s y FigPos(3)-2*s s])
% Text
TextPos = get(this.HG.StatusText,'Position');   % in pixels
set(this.HG.StatusText,'Position',[TextPos(1:2),FigPos(3)-2*TextPos(1),TextPos(4)]);

