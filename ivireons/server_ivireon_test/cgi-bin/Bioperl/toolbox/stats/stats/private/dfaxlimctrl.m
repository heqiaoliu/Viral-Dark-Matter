function dfaxlimctrl(dffig,onoff)
%DFAXLIMCTRL Turn on or off the controls for adjusting axis limits

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:33 $ 
%   Copyright 2001-2008 The MathWorks, Inc.

% Remove controls from figure if requested
if isequal(onoff,'off')
   a = findall(dffig,'Tag','axlimctrl');
   for j=1:length(a)
       ud = get(a(j),'UserData');
       if iscell(ud) && numel(ud)>=3 && isa(ud{3},'handle.listener')
           delete(ud{3});
       end
   end
   delete(a);
   return
end

% Add controls to figure.
% First find all axes in figure and their limits
ax1 = get(dffig,'CurrentAxes');
lims = get(ax1,'XLim');
lims(3:4) = get(ax1,'YLim');

% Create an arrow for labeling button controls
fcolor = get(dffig,'Color');
ar = ...
[0 1 1 1 1
 0 0 1 1 1
 0 0 0 1 1
 0 0 0 0 1
 0 0 0 0 0
 0 0 0 0 1
 0 0 0 1 1
 0 0 1 1 1
 0 1 1 1 1];

ar = repmat(ar,[1 1 3]);
ar(:,:,1) = min(ar(:,:,1),fcolor(1));
ar(:,:,2) = min(ar(:,:,2),fcolor(2));
ar(:,:,3) = min(ar(:,:,3),fcolor(3));

% Find axes position in pixel units
axpos = hgconvertunits(dffig,get(ax1,'position'),get(ax1,'units'),'pixels',dffig);
axbottom = ax1;
axbottompos = axpos;

% Compute the dimensions to use for text fields

% First get the longest axis limit and measure it in an edit control
samptxt= '';
for j=1:length(lims)
   newtxt = num2str(lims(j));
   if length(newtxt)>length(samptxt)
      samptxt = newtxt;
   end
end
if length(samptxt)<7
   samptxt = samptxt(min(length(samptxt),1:7));
end
temph = uicontrol(dffig,'style','edit','string',samptxt,...
                  'position',[1 1 300 10],'Visible','off');
extent = get(temph,'extent');
extent(4) = extent(4) * 1.25;
delete(temph);

% Next measure the y axis tick labels in a text control
ytxt = get(ax1,'YTickLabel');
ytxt(:,end+1) = ' ';
a = uicontrol(dffig,'style','text','string',ytxt,...
              'position',[1 1 300 10],'visible','off');
e = get(a,'Extent');
tickwidth = e(3);
delete(a);

% Reserve room for the controls
bht = ceil(extent(4)/2);     % arrow button height
bwd = ceil(1.5*bht);         % arrow button width
if axbottompos(2)<6*bht
   oldtop = axbottompos(2)+axbottompos(4);
   axbottompos(2) = 6*bht;
   axbottompos(4) = max(1,oldtop - axbottompos(2));
   set(axbottom,'Position',hgconvertunits(dffig,axbottompos,'pixels',...
                                          get(axbottom,'units'),dffig));
   axpos = axbottompos;
end
leftlim = 1 + extent(3) + bwd + tickwidth;
if axbottompos(1)<leftlim
   % Get figure width and make sure to stay in bounds
   figpos = hgconvertunits(dffig,get(dffig,'position'),get(dffig,'units'),...
                           'pixels',0);
   
   oldright = min(axbottompos(1)+axbottompos(3),figpos(3)-bwd-extent(3)/2);
   axbottompos(1) = max(axbottompos(1),leftlim);
   axbottompos(3) = max(1,oldright - leftlim);
   axbottompos(4) = max(1,axbottompos(4));
   set(axbottom,'Position',hgconvertunits(dffig,axbottompos,'pixels',...
                                          get(axbottom,'units'),dffig));
   axpos = axbottompos;
end

% Add controls to the y axis
h1 = addctrl(ar,extent,ax1,'ylo',axpos,bht,bwd);
h2 = addctrl(ar,extent,ax1,'yhi',axpos,bht,bwd);
lsnr = addlistener(ax1, 'YLim', 'PostSet', ...
                   @(src,evt) localUpdateText(ax1,'y',h1,h2));
ud = get(h1,'UserData');
ud{3} = lsnr;
set(h1,'UserData',ud);

% If y axis is on the probability scale, update the limit text now
localUpdateText(ax1, 'y', h1, h2)

% Add controls to the x axis
h1 = addctrl(ar,extent,ax1,'xlo',axpos,bht,bwd);
h2 = addctrl(ar,extent,ax1,'xhi',axpos,bht,bwd);
lsnr = addlistener(ax1, 'XLim', 'PostSet', ...
                   @(src,evt) localUpdateText(ax1,'x',h1,h2));
ud = get(h1,'UserData');
ud{3} = lsnr;
set(h1,'UserData',ud);

% ------------ Add a control to adjust an axis limit
function [htxt,h1,h2] = addctrl(ar,extent,ax,edge,axpos,bht,bwd)

f = get(ax,'Parent');

udtext = sprintf('%st',edge);
udup   = sprintf('%su',edge);
uddown = sprintf('%sd',edge);

xlim = get(ax,'XLim');
ylim = get(ax,'YLim');

% Compute desired text field position
if edge(1)=='x'
   if isequal(edge,'xlo')
      xcenter = axpos(1);
      txt = xlim(1);
      txtlabel = xlate('X Lower Limit');
   else
      xcenter = axpos(1) + axpos(3);
      txt = xlim(2);
      txtlabel = xlate('X Upper Limit');
   end
   extent(1) = xcenter - extent(3)/2;
   extent(2) = max(2*bht, axpos(2)-4*bht);
   extent(4) = 2*bht;
   labelpos = -1;
else
   if isequal(edge,'ylo')
      ycenter = axpos(2);
      txt = ylim(1);
      txtlabel = xlate('Y Lower Limit');
   else
      ycenter = axpos(2) + axpos(4);
      txt = ylim(2);
      txtlabel = xlate('Y Upper Limit');
   end
   extent(1) = 1;
   extent(2) = ycenter - bht;
   extent(4) = 2*bht;
   labelpos = 1;
end

% Create the text-entry field and arrow buttons, and position them
htxt = uicontrol(f,'Style','edit','String',num2str(txt),...
                 'Position',extent,'Userdata',{udtext ax 0},...
                 'Tag','axlimctrl',...
                 'Callback',{@doscroll ax},'BackgroundColor','w');
xright = extent(1)+extent(3);
ybndry = extent(2);
h1 = makearrow(bht,bwd,ax,f,ar,'t',xright,ybndry+bht);
set(h1,'Userdata',{udup ax htxt});
h2 = makearrow(bht,bwd,ax,f,ar,'b',xright,ybndry);
set(h2,'Userdata',{uddown ax htxt});

% Place a label under the text field
extent(2) = extent(2) + labelpos*extent(4);
extent(3) = 10*extent(3);
h = uicontrol(f,'Style','text','Position',extent,...
                'Tag','axlimctrl','Visible','off');

[txtlabel,newpos] = textwrap(h,{txtlabel});
set(h,'String',txtlabel{1},'Position',newpos,'Visible','on');

% ----------- create an arrow control in the specified direction
function h = makearrow(bht,bwd,ax,f,ar,direct,pleft,pbot)

% Point cdata arrow in the right direction
switch direct
 case {'b' 'l'}, ar = permute(ar,[2 1 3]);
 case {'t' 'r'}, ar = permute(ar,[2 1 3]); ar = ar(end:-1:1,:,:);
end

% Position and size button correctly
pos = [pleft pbot bwd bht];
h = uicontrol(f,'Style','pushbutton','CData',ar,'Tag','axlimctrl',...
                'Units','pixel','Position',pos,...
                'Callback',{@doscroll ax});


% ------------- callback for these controls
function doscroll(btn,xxx,ax);

% Get current tick locations and axis limits
ud = get(btn,'Userdata');  %btn may be a button or edit control handle
opt = ud{1};
if opt(1)=='x'
   limname = 'XLim';
   locs = get(ax,'XTick');
   logscale = isequal(get(ax,'XScale'),'log');
   fixedlabels = isequal(get(ax,'XTickLabelMode'),'manual');
else
   limname = 'YLim';
   locs = get(ax,'YTick');
   logscale = isequal(get(ax,'YScale'),'log');
   fixedlabels = isequal(get(ax,'YTickLabelMode'),'manual');
end
lims = get(ax,limname);
if opt(2)=='h'
   limindex = 2;
else
   limindex = 1;
end

% Update based on typed-in value or on button press
if opt(4)=='t'
   % Evaluate new entry in text box
   try
      curval = str2double(get(btn,'String'));
   catch
      curval = [];
   end
   if isempty(curval) || ~isfinite(curval)
      return
   end
   if opt(1)=='y'
      invcdffun = getappdata(ax,'InverseCdfFunction');
      if ~isempty(invcdffun)
         params = getappdata(ax,'DistributionParameters');
         curval = feval(invcdffun,curval,params{:});
      end
   end
   if (limindex==1 && curval>=lims(2)) || (limindex==2 && curval<=lims(1))
      return
   end
   
else
   % Button press
   
   % If tick locations are not automatic, extend with more locations on each end
   if ~fixedlabels
      if logscale
         % For log scale there are major and minor ticks, but we have no access
         % to the minor tick labels or locations.  Deal with this by creating
         % arrays of tick labels likely to match the union of the major and
         % minor ticks.
         majorlo = min(locs);
         while(majorlo/10 >= lims(1))
            majorlo = majorlo/10;
         end
         majorhi = max(locs);
         while(majorhi*10 <= lims(2))
            majorhi = majorhi*10;
         end
         locs = [majorlo.*[(1:9)/10, (1:9)], ...
                 majorhi.*[(2:9)/10, (1:10)]]';
         locs = sort(locs);
         locs(diff(locs)==0) = [];
      else
         % For linear scale just add two more entries on each end,
         % one in case we move past the end and another in case the
         % end tick is just beyond the end by a small amount
         delta = locs(2)-locs(1);
         locs = [locs(1)-2*delta, locs(1)-delta, locs, ...
                 locs(end)+delta, locs(end)+2*delta];
      end
   end

   % Get current value of the most extreme tick label within bounds
   if logscale
      small = sqrt(eps);
   else
      small = max(abs(lims))*sqrt(eps);
   end
   if opt(2)=='h'
      limindex = 2;
      if logscale
         jcurtick = sum(locs<lims(2)*(1+small));
      else
         jcurtick = sum(locs<lims(2)+small);
      end
   else
      limindex = 1;
      if logscale
         jcurtick = sum(locs<lims(1)*(1-small))+1;
      else
         jcurtick = sum(locs<lims(1)-small)+1;
      end
   end
   jcurtick = max(1, min(length(locs), jcurtick));
   curtick = locs(jcurtick);
   curlim = lims(limindex);
   if logscale
      ontick = (abs(curtick - curlim) < small*curtick);
   else
      ontick = (abs(curtick - curlim) < small);
   end

   % Move to the next entry in the sequence of tick locations
   if opt(4)=='u'
      if ontick || opt(2)=='h'
         jcurtick = min(length(locs),jcurtick+1);
      end         
   else
      if ontick || opt(2)=='l'
         jcurtick = max(1,jcurtick-1);
      end
   end
   curval = locs(jcurtick);
end

% Update the axis limits
if ~isfinite(curval)
   warndlg('Bad axis limit value.','Distribution Fitting Tool');
   return;
end
otherlimindex = 3-limindex;
if curval ~= lims(otherlimindex)
   lims(limindex) = curval;
end
if opt(1)=='x'
   dfupdatexlim(lims);
else
   set(ax,limname,lims);
end


% ----------- update text fields when axis limits change
function localUpdateText(ax, xory, hlo, hhi)

% Get information about the axis in question
tickloc = [];
if xory=='x'
   lim = get(ax,'XLim');
   if isequal(get(ax,'XTickLabelMode'),'manual')
      tickloc = get(ax,'XTick');
      ticklabel = get(ax,'XTickLabel');
   end
   cdffun = '';
   logscale = isequal(get(ax,'XScale'),'log');
else
   lim = get(ax,'YLim');
   if isequal(get(ax,'YTickLabelMode'),'manual')
      tickloc = get(ax,'YTick');
      ticklabel = get(ax,'YTickLabel');
   end
   cdffun = getappdata(ax,'CdfFunction');
   if ~isempty(cdffun)
      params = getappdata(ax,'DistributionParameters');
   end
   logscale = isequal(get(ax,'XScale'),'log');
end

% Loop over the low and high values, and update text box with limits
hvec = [hlo hhi];
small = max(abs(lim))*sqrt(eps);
for jLim=1:2
   newval = lim(jLim);
   if ~isempty(tickloc) && any(abs(tickloc-newval) < small)
      % If this tick has a label already made, use it
      j = find(abs(tickloc-newval) < small);
      j = j(1);
      newval = deblank(ticklabel(j,:));
   else
      % Otherwise make a new label, calling cdf function if necessary
      if ~isempty(cdffun)
         newval = feval(cdffun,newval,params{:});
      end
      if abs(newval)<small && ~logscale
         % Just to get 0 instead of ~eps when appropriate
         newval = '0';
      else
         newval = num2str(newval);
      end
   end
   set(hvec(jLim),'String',newval);
end
