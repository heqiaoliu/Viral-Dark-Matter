function updatelims(this)
%UPDATELIMS  Limit picker for freq plots.
%
%   UPDATELIMS(H) computes:
%     1) an adequate X range from the data or source
%     2) common Y limits across rows for axes in auto mode.

% Copyright 2004-2005 The MathWorks, Inc.

%  Overloaded to enable fre domain limit picking

AxesGrid = this.AxesGrid;
% Update X range by merging time Focus of all visible data objects.
% RE: Do not use SETXLIM in order to preserve XlimMode='auto'
% REVISIT: make it unit aware
ax = getaxes(this);
AutoX = strcmp(AxesGrid.XLimMode,'auto');
if any(AutoX)
   set(ax(:,AutoX),'Xlim', getfocus(this));
end

if strcmp(AxesGrid.YNormalization,'on')
   % Reset auto limits to [0,1] range
   set(ax(strcmp(AxesGrid.YLimMode,'auto'),:),'Ylim',[0 1])
else
   % Update Y limits
   AxesGrid.updatelims('manual', [])
end

%% Get freq extent
xlims = AxesGrid.getxlim{1};
S = warning('off','all');
for k=1:length(this.Waves)
    if ~isempty(this.Waves(k).Data.Response)
        if (0<this.Waves(k).Data.Frequency(1) && ...
            this.Waves(k).Data.Frequency(1)>xlims(1)) || ...
            (this.Waves(k).Data.NyquistFreq>this.Waves(k).Data.Frequency(end) && ...
            this.Waves(k).Data.Frequency(end)<xlims(2))
            this.Waves(k).DataSrc.send('sourcechange')
        end  
    end
end
warning(S);

if ~isempty(this.PropEditor)
    this.PropEditor.axespanel(this,'Y');
    this.updatechartable(this.PropEditor);
end