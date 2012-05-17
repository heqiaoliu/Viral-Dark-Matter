function this = HSVPlotOptions(varargin)
%HSVPLOTOPTIONS

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:25 $
this = plotopts.HSVPlotOptions;

% Set Version Number
this.Version = 1.0;

if any(strcmpi(varargin,'cstprefs'))
   mapCSTPrefs(this); 
end

this.Title.String = ctrlMsgUtils.message('Controllib:plots:strHSVTitle');
this.XLabel.String = ctrlMsgUtils.message('Controllib:plots:strState');
this.YLabel.String = ctrlMsgUtils.message('Controllib:plots:strStateEnergy');
this.Grid = 'on';  % on by default