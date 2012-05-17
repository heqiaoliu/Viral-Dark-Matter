function installtip(this,gobjects,tipfcn,info)
%INSTALLTIP  Installs point tip on specified G-objects.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/11/27 22:43:42 $

%% Overloaded to use point tips rather than the linetip

if isempty(tipfcn)
   % Clear tip function
   BDF = '';
else
   BDF = {@LocalButtonDownFcn tipfcn info};
end
set(gobjects,'ButtonDownFcn',BDF)

for ct = 1:length(gobjects)
    set(gobjects(ct),'handlevisibility','off')
    %% Get the behavior object
    hb = hggetbehavior(gobjects(ct),'DataCursor');
    if iscell(tipfcn)
        set(hb,'UpdateFcn',{tipfcn{1} info tipfcn{2:end}});
    else
        set(hb,'UpdateFcn',{tipfcn info});
    end
    pe = hggetbehavior(gobjects(ct),'PlotEdit');
    pe.Enable = false;
end

%%%%%%%%%%  Local Functions   %%%%%%%%%%  

function tip = LocalButtonDownFcn(EventSrc,EventData,tipfcn,info)
% Creates data tip and sets its tip function

if ~isa(info.View.LineTips{info.Row,info.Col},'graphics.datatip')
    %% Create the datatip
    % try-catch is a workaround on an HG error with handling datatips.
    try
        tip = pointtip(info.View.Lines(info.Row,info.Col),info.TipOptions{:});
    catch
        tip = [];
        return
    end
    LineTips = info.View.LineTips;
    LineTips{info.Row,info.Col} = tip;
    info.View.LineTips = LineTips;
    tip.render;
else
    tip = [];
end
