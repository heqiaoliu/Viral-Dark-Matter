function this = BodePlotOptions(varargin)
%BODEPLOTOPTIONS

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:20 $

this = plotopts.BodePlotOptions;

% Set Version Number
this.Version = 1.0;

if ~isempty(varargin) && strcmpi(varargin{1},'cstprefs')
   mapCSTPrefs(this); 
end

this.Title.String = ctrlMsgUtils.message('Controllib:plots:strBodeDiagram');
this.XLabel.String = ctrlMsgUtils.message('Controllib:plots:strFrequency');
this.YLabel.String = {ctrlMsgUtils.message('Controllib:plots:strMagnitude'), ...
    ctrlMsgUtils.message('Controllib:plots:strPhase')};