function this = idnlarxplot(datahandles,num,isGUI)
%idnlarxplot constructor
% accepts an array of model handles (nlarxdata objects) as input.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:20 $

this = plotpack.idnlarxplot;
this.ModelData = datahandles;

if nargin<2
    num = 20;
end

if nargin<3
    isGUI = false;
end

this.NumSample = num;
this.isGUI = isGUI;

L = length(this.ModelData);
this.OutputNames = this.getOutputNames;
this.Current.MultiOutputAxesTag = this.OutputNames{1};

% update regressor info
for k = 1:L
    this.addRegData(this.ModelData(k));
end

% update list of active regressors for all RegressorData elements
this.updateActiveRegressors;

% assign model colors
% color is used only by GUI; plot command uses StyleArg
map = idlayout('colors');
map = [map(end,:);map(1:end-1,:)];
% if this.isDark
%     % Dark background.
%     colord = {'b','y','m','c','r','g','w'};
% else
%     % Light background
%     colord = {'k','b','g','r','c','m','y'};
% end

% assign default colors and styles
Lc = size(map,1);
for k = 1:L
    if isempty(this.ModelData(k).Color)
        this.ModelData(k).Color = map(rem(k,Lc)+1,:);
    end
%     if isempty(this.ModelData(k).StyleArg)
%         this.ModelData(k).StyleArg = colord(rem(k,7)+1);
%     end
end

if ~isempty(this.ModelData) && all(ishandle(this.ModelData))
    this.initializePlot;
end
