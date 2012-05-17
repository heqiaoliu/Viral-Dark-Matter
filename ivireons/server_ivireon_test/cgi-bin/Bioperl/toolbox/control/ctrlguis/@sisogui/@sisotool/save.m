function SessionData = save(this)
%SAVE   Creates SISO Tool backup for Save Session.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2007/05/18 04:59:25 $

% Version history
% 1.0 -> R12.1
% 2.0 -> R13
SessionData = sisogui.session;

% Save current design and add saved designs
CurrentDesign = exportdesign(this.LoopData);
SessionData.Designs = [CurrentDesign ; this.LoopData.History];

% Save history
SessionData.History = gethistory(this.EventManager);

% Save preferences
SessionData.Preferences = save(this.Preferences);

% Save editor settings
if isempty(this.PlotEditors)
    s = {};
else
ed = find(this.PlotEditors,'-not','EditedLoop',-1);
for ct=length(ed):-1:1
   s(ct,1) = {save(ed(ct))};
end
end
SessionData.EditorSettings = s;

% Save Viewer Data
% This saves plottype and constraints for each plot so they can be reloaded
LTIViewer = this.AnalysisView;
if ~isempty(LTIViewer)
    for ct = 1:6;
        PlotCell = LTIViewer.PlotCell{ct};
        idx = 1;
        CellInfo = struct('PlotType',[],...
            'Constraints',[]);
        for ct2 = 1:length(PlotCell)
            if ~isempty(PlotCell(1))
                CellInfo(idx) = struct('PlotType',get(PlotCell(ct2),'tag'),...
                    'Constraints',PlotCell(ct2).saveconstr);
                idx = idx +1;
            end
        end
        ViewerData(ct).PlotCell = CellInfo;
    end
else
    ViewerData = [];
end

% Save Viewer settings
% This saves settings with respect to what plots are visible
ViewerContents = getViewerContents(this);
if ~isempty(ViewerContents)
   % Save menu states
   Menus = handle(this.HG.Menus.Analysis.PlotSelection);
   Viewer = this.AnalysisView;
   ViewerContents(1).SelectedMenu = [];  % Add field to keep track of selected menus
   for ct=1:length(Menus)
      if strcmp(Menus(ct).Checked,'on')
         ViewerContents(Menus(ct).UserData.View==Viewer.Views).SelectedMenu = ct;
      end
   end
end
SessionData.ViewerSettings = struct('ViewerData', ViewerData, ...
    'ViewerContents',ViewerContents);


