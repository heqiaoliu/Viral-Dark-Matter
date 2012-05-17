function setSystems(this,LoopData)
% Configures the SISO Tool Viewer to show a particular list of loop
% transfer functions. 
%
% RE: SETSYSTEM initializes responses with Visible=off and makes all
%     views invisible. It should be followed by appropriate calls
%     to setContents.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2006/06/20 20:03:32 $
LoopTFs = LoopData.LoopView;
nsys = length(LoopTFs);

% Performance optimization: regenerate responses only when set of loop
% transfer functions changes.
if nsys==length(this.SystemInfo) && ...
      isequal(get(LoopTFs,{'Type','Index'}),get(this.SystemInfo,{'Type','Index'}))
   % No change in set of loop transfer functions
   for ct=1:nsys
      % Update source names
      this.Systems(ct).Name = LoopTFs(ct).Description;
   end
else
   % New set of loop transfer functions
   % Make all views invisible (otherwise code below will trigger plotting of
   % all systems in visible views)
   ActiveViews = this.Views(ishandle(this.Views));
   set(ActiveViews,'Visible','off')

   % Create one data source per loop transfer
   for ct=1:nsys
      sys = getmodel(LoopData,LoopTFs(ct));  % get loop transfer as @lti model
      src(ct,1) = resppack.ltisource(sys,'Name',LoopTFs(ct).Description);
   end
   this.Systems = src;

   % Initialize response visibility to off
   for ct=1:length(ActiveViews)
      set(ActiveViews(ct).Response(1:nsys),'Visible','off')
   end
end

% Store system info
this.SystemInfo = LoopTFs;

% Apply pre-defined styles
for ct=1:nsys
   this.setstyle(this.Systems(ct),LoopTFs(ct).Style)
end
