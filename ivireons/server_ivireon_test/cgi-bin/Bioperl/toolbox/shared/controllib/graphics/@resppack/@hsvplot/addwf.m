function wf = addwf(this, varargin)
%ADDWF  Adds an @hsvchart to an HSV plot.
%
%   WF = ADDWF(PLOT) creates a new @hsvchart WF for the @plot instance 
%   PLOT.
%
%   WF = ADDWF(PLOT,DATASRC) links the chart to the data source DATASRC.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:57 $

% Create a new @hsvchart object
wf = resppack.hsvchart;
wf.Parent = this;

% Handle case where data source is supplied
if nargin==2
   DataSrc = varargin{1};
   if ~isa(DataSrc, 'wrfc.datasource')
       ctrlMsgUtils.error('Controllib:plots:addwf1', ...
           'addwf(HSVPLOT,DATASRC)','DATASRC','wrfc.datasource')
   end
   wf.DataSrc = DataSrc;
   wf.Name = DataSrc.Name;
end
   
% Initialize new @hsvchart
initialize(wf)

% Add default tip (tip function calls MAKETIP first on data source, then on view)
% addtip(wf)
