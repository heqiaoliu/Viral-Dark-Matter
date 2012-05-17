function this = idnlhwplot(plothandles,num,isGUI)
%idnlhwmodels constructor
% accepts an array of model handles (nlhw objects) as input.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:31 $

this = plotpack.idnlhwplot;

this.ModelData = plothandles;
this.NumSample = num;

if nargin<3
    isGUI = false;
end
this.isGUI = isGUI;

L = length(this.ModelData);
this.setIONames;

% initialize ranges
% (each axes has its own range)
%this.Range.Input = nan(length(this.IONames.u),2);
%this.Range.Output = nan(length(this.IONames.y),2);

% assign model colors
% color is used only by GUI; plot command uses StyleArg
map = idlayout('colors');
map = [map(end,:);map(1:end-1,:)];
if this.isDark
    % Dark background.
    colord = {'b','y','m','c','r','g','w'};
else
    % Light background
    colord = {'k','b','g','r','c','m','y'};
end

Lc = size(map,1);
for k = 1:L
    if isempty(this.ModelData(k).Color)
        this.ModelData(k).Color = map(rem(k,Lc)+1,:);
    end
    if isempty(this.ModelData(k).StyleArg)
        this.ModelData(k).StyleArg = colord(rem(k,7)+1);
    end
end

if ~isempty(this.ModelData) && all(ishandle(this.ModelData))
    this.initializePlot;
end

%set(this.Figure,'ResizeFcn',@(es,ed)executeResizeFcn(this));