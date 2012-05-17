function refresh(this, Mask)
%REFRESH  Adjusts visibility of low-level HG objects in SineView both for
%sine signal and steady state signal.
%
%  REFRESH(VIEW,MASK) adjusts the visibility of VIEW's HG 
%  objects taking into account external factors such as 
%    * data visibility and axes grouping (see REFRESHMASK)
%    * visibility of @dataview parent
%  These external factors are summarized by MASK. 
%  
%  REFRESH does not alter the VIEW's Visible state.

%  Author(s): Erman Korkut 17-Mar-2009
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:07 $

% RE: MASK is a logical array of the same size as the axes grid
gobj = ghandles(this);
ssobj = this.SSCurves;

Mask = Mask(:);
if any(Mask) & strcmp(this.Visible, 'on')
   nax = length(Mask);
   if nax==1
      set(gobj(ishandle(gobj)), 'Visible', 'on')
      set(ssobj(ishandle(gobj)), 'Visible', 'on')
   else
      gobj = reshape(gobj,[nax prod(size(gobj))/nax]);      
      VisibleObj = gobj(Mask,:);      
      set(VisibleObj(ishandle(VisibleObj)),'Visible','on')      
      HiddenObj = gobj(~Mask,:);      
      set(HiddenObj(ishandle(HiddenObj)),'Visible','off')
      % Repeat the same for steady state curves
      ssobj = reshape(ssobj,[nax prod(size(ssobj))/nax]);
      VisibleSSObj = ssobj(Mask,:);
      set(VisibleSSObj(ishandle(VisibleSSObj)),'Visible','on')
      HiddenSSObj = gobj(~Mask,:);
      set(HiddenSSObj(ishandle(HiddenSSObj)),'Visible','off')
   end
else
   set(gobj(ishandle(gobj)), 'Visible', 'off')
   set(ssobj(ishandle(ssobj)), 'Visible', 'off')   
end

