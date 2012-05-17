function updatelims(this)
%UPDATELIMS  Limit picker for xy plots.
%
%   UPDATELIMS(H) computes:
%     1) an adequate X range from the data or source
%     2) common Y limits across rows for axes in auto mode.

% Copyright 2004-2005 The MathWorks, Inc.

%  Overloaded to enable fre domain limit picking

AxesGrid = this.AxesGrid;
% Update X range by merging time Focus of all visible data objects.
% on each visible column RE: Do not use SETXLIM in order to preserve XlimMode='auto'
% REVISIT: make it unit aware
ax = this.getaxes('2d');
AutoX = find(strcmp(AxesGrid.XLimMode,'auto'));
for k=1:length(AutoX)
    set(ax(:,AutoX(k)),'Xlim', getfocus(this,AutoX(k)));
end

if strcmp(AxesGrid.YNormalization,'on')
   % Reset auto limits to [-1,1] range
   set(ax(strcmp(AxesGrid.YLimMode,'auto'),:),'Ylim',[-1.1 1.1])
else
   % Update Y limits
   AxesGrid.updatelims('manual', [])
end

if length(this.Responses)==0 || isempty(this.Responses(1).Data.Xdata) || ...
        isempty(this.Responses(1).Data.Ydata)
    return
end
if ~isempty(this.PropEditor)
    this.PropEditor.axespanel(this,'Y');
    this.PropEditor.axespanel(this,'X');
    this.PropEditor.updatechartable(this);
end
