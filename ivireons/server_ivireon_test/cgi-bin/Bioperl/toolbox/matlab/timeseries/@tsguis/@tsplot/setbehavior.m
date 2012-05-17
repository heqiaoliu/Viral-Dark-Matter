function setbehavior(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Customizes the behavior 
thisaxes = h.Axesgrid.getaxes;
for k=1:length(thisaxes)   
      ax_plotedit = hggetbehavior(thisaxes(k),'Plotedit');
      ax_plotedit.enable = false;
      ax_rotate3d = hggetbehavior(thisaxes(k),'Rotate3d');
      ax_rotate3d.enable = false;   
      ax_mcode = hggetbehavior(thisaxes(k),'MCodeGeneration');
      ax_mcode.enable = false;  
      ax_pan = hggetbehavior(thisaxes(k),'Pan');
      setappdata(thisaxes(k),'PanListeners',...
          [handle.listener(ax_pan,'BeginDrag',{@localPanBegin h});...
           handle.listener(ax_pan,'EndDrag',{@localPanEnd h})]);
end
 

function localPanBegin(es,ed,h)

h.AxesGrid.xlimmode = 'manual'; % Must be manual so that pans dont revert
h.AxesGrid.Limitmanager = 'off';

function localPanEnd(es,ed,h)

h.AxesGrid.Limitmanager = 'on';
h.AxesGrid.send('viewchange')
 