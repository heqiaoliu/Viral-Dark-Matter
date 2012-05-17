function configure(this,varargin)
% Reconfigures editor when configuration or target changes

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:59:19 $
if strcmp(this.Visible,'on')
   [L,idxL] = getL(this);
   % Update title
   if isempty(L.Name) || strcmp(L.Name,L.Identifier)
      this.Axes.Title = sprintf('Open-Loop Nichols Editor for %s',L.Identifier);
   else
      this.Axes.Title = sprintf('Open-Loop Nichols Editor for %s (%s)',L.Name,L.Identifier);
   end
   % Updates editor's dependency list Revisit
   this.Dependency = this.getDependency;
   
   % Initialize Targets
   this.initializeCompTarget;
   
   % Turn on multi-model characteristics
   if isUncertain(L) 
       % Enable Multi Model Menu
       setmenu(this,'on','multiplemodel')
       % If not visible show menu
       if ~this.UncertainBounds.isVisible
           this.UncertainBounds.Visible = 'on';
           this.update;
       end
   else
       % Disable Multi Model Menu
       setmenu(this,'off','multiplemodel')
       this.UncertainBounds.Visible = 'off';
   end
end

