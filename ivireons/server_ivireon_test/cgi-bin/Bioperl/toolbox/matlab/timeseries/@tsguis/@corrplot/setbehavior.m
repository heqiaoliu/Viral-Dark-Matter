function setbehavior(h)

% Copyright 2004 The MathWorks, Inc.

%% Customizes the behavior 
thisaxes = h.Axesgrid.getaxes;
 for k=1:prod(size(thisaxes))   
      ax_plotedit = hggetbehavior(thisaxes(k),'Plotedit');
      ax_plotedit.enable = false;
      ax_rotate3d = hggetbehavior(thisaxes(k),'Rotate3d');
      ax_rotate3d.enable = false;   
      ax_mcode = hggetbehavior(thisaxes(k),'MCodeGeneration');
      ax_mcode.enable = false;         
 end
 