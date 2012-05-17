function this = SigmaPlotOptions(varargin)
%SIGMAPLOTOPTIONS

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:18:00 $

this = plotopts.SigmaPlotOptions;

% Set Version Number
this.Version = 1.0;

if ~isempty(varargin) && strcmpi(varargin{1},'cstprefs')
   mapCSTPrefs(this); 
end

this.Title.String = ctrlMsgUtils.message('Controllib:plots:strSingularValues');
this.XLabel.String = ctrlMsgUtils.message('Controllib:plots:strFrequency');
this.YLabel.String = ctrlMsgUtils.message('Controllib:plots:strSingularValues');