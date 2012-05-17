function refresh(this, Mask)
%REFRESH  Adjusts visibility of low-level HG objects.
%
%  REFRESH(VIEW,MASK) adjusts the visibility of VIEW's HG 
%  objects taking into account external factors such as 
%    * data visibility and axes grouping (see REFRESHMASK)
%    * visibility of @dataview parent
%  These external factors are summarized by MASK. 
%  
%  REFRESH does not alter the VIEW's Visible state.

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2008/12/29 02:11:43 $

% RE: MASK is a logical array of the same size as the axes grid

% Overloaded to set the visibility of selected curves
gobj = ghandles(this);
Mask = Mask(:);
if any(Mask) & strcmp(this.Visible, 'on')
   nax = length(Mask);
   if nax==1
      set(gobj(ishghandle(gobj)), 'Visible', 'on')
      set(this.SelectionCurves , 'Visible', 'on')
   else
      gobj = reshape(gobj,[nax prod(size(gobj))/nax]);
      selobj = reshape(this.SelectionCurves,[nax prod(size(this.SelectionCurves))/nax]);
      VisibleObj = gobj(Mask,:);
      selVisibleObj = selobj(Mask,:);
      set(VisibleObj(ishghandle(VisibleObj)),'Visible','on')
      set(selVisibleObj(ishghandle(selVisibleObj)),'Visible','on')
      HiddenObj = gobj(~Mask,:);
      selHiddenObj = selobj(~Mask,:);
      set(selHiddenObj(ishghandle(selHiddenObj)),'Visible','off')
      set(HiddenObj(ishghandle(HiddenObj)),'Visible','off')
   end
else
   set(gobj(ishghandle(gobj)), 'Visible', 'off')
   set(this.SelectionCurves , 'Visible', 'off')
end
