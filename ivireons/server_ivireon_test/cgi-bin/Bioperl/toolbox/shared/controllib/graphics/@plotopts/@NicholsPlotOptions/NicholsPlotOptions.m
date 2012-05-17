function this = NicholsPlotOptions(varargin)
%NICHOLSPLOTOPTIONS

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:30 $

this = plotopts.NicholsPlotOptions;

% Set Version Number
this.Version = 1.0;

if ~isempty(varargin) && strcmpi(varargin{1},'cstprefs')
   mapCSTPrefs(this); 
end

this.Title.String = ctrlMsgUtils.message('Controllib:plots:strNicholsChart');
this.XLabel.String = ctrlMsgUtils.message('Controllib:plots:strOpenLoopPhase');
this.YLabel.String = ctrlMsgUtils.message('Controllib:plots:strOpenLoopGain');