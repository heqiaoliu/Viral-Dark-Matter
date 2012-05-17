function refresh(this,Mask)
%REFRESH  Adjusts visibility of @dataview's HG components.
%
%  REFRESH(DATAVIEW,MASK) adjusts the visibility of DATAVIEW's
%  graphical components (low-level HG objects).  The optional 
%  argument MASK specifies the visibility of each data cell (see  
%  REFRESHMASK for details).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:04 $

% Visibility of parent views
ParentVis = strcmp(this.Parent.Visible,'on');
if isa(this.Parent,'wrfc.dataview')
   ParentVis = ParentVis & strcmp(get(this.Parent.View, 'Visible'), 'on');
end

% Visibility mask (relative to the full axes grid)
if strcmp(this.Visible,'off')
   Mask = false;
elseif nargin==1
   Mask = refreshmask(this.Parent);
end

% Update effective visibility of each view
for ct=1:length(this.View)
   this.View(ct).refresh(Mask & ParentVis(min(ct,end)));
end
