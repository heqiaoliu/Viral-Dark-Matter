function localize(this)
%LOCALIZE  Updates @siminput wave when plot size changes.

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:24 $
Ny = length(getrcname(this.Parent));  % row size

if length(this.RowIndex)~=Ny
   % Expand input plot to fill all available rows
   set(this.Listeners,'Enable','off')
   this.RowIndex = 1:Ny;
   set(this.Listeners,'Enable','on')
   
    % Adjust number of curves to match output dimension
   for v = this.View'
      resize(v,Ny)
   end
   for c = this.Characteristics'
      for v = c.View'
         resize(v,Ny)
      end
   end
   
   % Adjust number of groups for axes
   ngroups = length(this.Group);
   Axes = getaxes(this);
   nAxes = numel(Axes);
   if ngroups <= nAxes
       % add groups
       for ct = ngroups:nAxes
           this.Group(ct) = handle(hggroup('parent',Axes(ct)));
           hasbehavior(this.Group(ct),'legend',false)
       end
   else
       % remove excess groups
       delete(this.Group(nAxes+1:end));
       this.Group(nAxes+1:end) = [];
   end
   
   % Update graphics
   reparent(this)
end
