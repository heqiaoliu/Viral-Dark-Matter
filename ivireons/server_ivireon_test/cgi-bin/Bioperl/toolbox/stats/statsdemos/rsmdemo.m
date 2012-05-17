function rsmdemo(action,figarg)
%RSMDEMO Demo of design of experiments and surface fitting.
%   RSMDEMO Creates a GUI that simulates a chemical reaction.
%   To start, you have a budget of 13 test reactions. Try to find out how
%   changes in each reactant affect the reaction rate. Determine the 
%   reactant settings that maximize the reaction rate. Estimate the
%   run-to-run variability of the reaction.
%
%   Now run a designed experiment using the model popup. Compare your
%   previous results with the output from response surface modeling or
%   nonlinear modeling of the reaction.
%
%   The GUI has the following elements:
%   1) A RUN button to perform one reactor run at the current settings.
%   2) An Export button to export the X and Y data to the base workspace.
%   3) Three sliders with associated data entry boxes to control the 
%      partial pressures of the chemical reactants: Hydrogen, n-Pentane,
%      and Isopentane.
%   4) A text box to report the reaction rate.
%   5) A text box to keep track of the number of test reactions you have
%      left.
%
%   See also CORDEXCH, RSTOOL, NLINTOOL, HOUGEN.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/07/01 20:44:45 $

if nargin < 1
    action = 'start';
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')
   if (nargin>1 && length(figarg)==3)
      fact_fig = figarg(1);
      data_fig = figarg(2);
      doe_fig = figarg(3);
   else
      fact_fig = findobj(0,'Tag','control');
      data_fig = findobj(0,'Tag','data1');
      doe_fig  = findobj(0,'Tag','data2');
   end
end

if ~strcmp(action,'start') && ~strcmp(action,'close')
  p1field = findobj(fact_fig,'Tag','p1f');
  p1slider = findobj(fact_fig,'Tag','p1s');
  
  p2field = findobj(fact_fig,'Tag','p2f');
  p2slider = findobj(fact_fig,'Tag','p2s');
  
  p3field = findobj(fact_fig,'Tag','p3f');
  p3slider = findobj(fact_fig,'Tag','p3s');

  out_field = findobj(fact_fig,'Tag','of');
  runs_field = findobj(fact_fig,'Tag','rf');
  run_btn   = findobj(fact_fig,'Tag','rb');
  reset_btn = findobj(fact_fig,'Tag','rs');   

  if ~isempty(data_fig);
     p1_popup   = findobj(data_fig,'Tag','popup1');
  end

  if ~isempty(doe_fig);
     p2_popup   = findobj(doe_fig,'Tag','popup2');
  end
  plat = computer;
  if strcmp(plat(1:2),'PC')
     fs = 8;
  else
     fs = 9;
  end
end

if strcmp(action,'start')
   
   plat = computer;
   if strcmp(plat(1:2),'PC')
      fs = 8;
   else
      fs = 9;
   end
   fpadj = -50;

% Initialize data values.
p1   = 200;
p1hi = 470;
p1lo = 100;
p2   = 150;
p2hi = 300;
p2lo = 80;

p3   = 50;
p3hi = 120;
p3lo = 10;

% Define graphics objects
fieldp1 = [120 80 80 20];
slidep1 = fieldp1 + [85 -60 -65 80];
textp1  = fieldp1 + [0 20 0 0];
fieldp2 = [240 80 80 20];
slidep2 = fieldp2 + [85 -60 -65 80];
textp2  = fieldp2 + [0 20 0 0];
fieldp3 = [360 80 80 20];
slidep3 = fieldp3 + [85 -60 -65 80];
textp3  = fieldp3 + [0 20 0 0];

% Create Reaction Simulator Figure
set(0,'Units','pixels')
ss = get(0,'ScreenSize');
pos1 = [10 ss(4)-210+fpadj 480 200];

grey = get(0,'defaultuicontrolbackgroundcolor');
fact_fig = figure('Units','pixels','Position',pos1,'Color',grey, ...
                  'WindowStyle','Normal','DockControls','off','Resize','off');

drawnow;
pos1 = get(fact_fig, 'Position');
opos = get(fact_fig, 'OuterPosition');

posdy = opos(4) - pos1(4);
posdx = opos(3) - pos1(3);

pos2 = [pos1(1) (pos1(2)-posdy-200) 355 210];
data_fig = figure('Visible','off','Units','pixels',...
                  'Position',pos2,'BusyAction','cancel',...
                  'WindowStyle', 'Normal', ...
                  'DockControls', 'off');

pos3 = [(pos2(1)+pos2(3)+posdx) pos2(2) 355 210];
doe_fig = figure('Visible','off','Units','pixels',...
                 'Position',pos3,'BusyAction','cancel',...
                  'WindowStyle', 'Normal', ...
                  'DockControls', 'off');

figlist = [fact_fig data_fig doe_fig];
set(0,'CurrentFigure',fact_fig);

set(fact_fig,...
    'Name','Reaction Simulator','Tag','control','BusyAction','cancel');

uicontrol('Style','edit','Units','pixels','Position',fieldp1,...
         'BackgroundColor','white','String',num2str(p1),'Tag','p1f',...
       'Callback',@(varargin)rsmdemo('setp1field',figlist));
         
uicontrol('Style','slider','Units','pixels','Position',slidep1,...
        'Value',p1,'Max',p1hi,'Min',p1lo,...
        'Callback',@(varargin)rsmdemo('setp1slider',figlist),'Tag','p1s');

uicontrol('Style','text','Units','pixels','Position',textp1,...
          'String','Hydrogen');

uicontrol('Style','edit', 'Units','pixels','Position',fieldp2,...
       'BackgroundColor','white','String',num2str(p2),'Tag','p2f',...
      'Callback',@(varargin)rsmdemo('setp2field',figlist));

         
uicontrol('Style','slider','Units','pixels','Position',slidep2,...
        'Value',p2,'Max',p2hi,'Min',p2lo,...
        'Callback',@(varargin)rsmdemo('setp2slider',figlist),'Tag','p2s');
                           
uicontrol('Style','text','Units','pixels','Position',textp2,...
          'String','n-Pentane');

uicontrol('Style','edit','Units','pixels','Position',fieldp3,...
         'BackgroundColor','white','String',num2str(p3),'Tag','p3f',...
       'Callback',@(varargin)rsmdemo('setp3field',figlist));
         
uicontrol('Style','slider','Units','pixels','Position',slidep3,...
       'Value',p3,'Max',p3hi,'Min',p3lo,...
        'Callback',@(varargin)rsmdemo('setp3slider',figlist),'Tag','p3s');
                           
uicontrol('Style','text','Units','pixels','Position',textp3,...
          'String','Isopentane');


h1pos = [25 150 75 20];
h2pos = [25 170 75 20];
h1 = uicontrol('Style','text','Units','pixels','Position',h1pos,...
              'String','Reaction Rate:','Horizontalalignment','left');
h2 = uicontrol('Style','text','Units','pixels','Position',h2pos,...
              'String','Runs Left:','Horizontalalignment','left');
e1 = get(h1,'Extent');
e2 = get(h2,'Extent');
fwidth = max(e1(3),e2(3));
h1pos(3) = fwidth;
h2pos(3) = fwidth;
set(h1,'position',h1pos);
set(h2,'position',h2pos);

uicontrol('Style','text','Units','pixels','HorizontalAlignment','left',...
          'Position',[25+fwidth+5 150 70 20],'Tag','of');

uicontrol('Style','text','Units','pixels','HorizontalAlignment','left',...
          'String',num2str(13),...
          'Position',[25+fwidth+5 170 70 20],'Tag','rf');

makebutton([25 125 75 20],@(varargin)rsmdemo('reset',figlist),'rs','Reset','off');
makebutton([25 80 75 20],@(varargin)rsmdemo('run',figlist),'rb','Run');
makebutton([25 55 75 20],@(varargin)rsmdemo('output',figlist),'','Export...');
makebutton([375 170 100 20],@(varargin)rsmdemo('help',figlist),'','Help');
makebutton([25 10 75 20],@(varargin)rsmdemo('close',figlist),'','Close');

set(fact_fig,'DeleteFcn',@(varargin)rsmdemo('close',figlist));

% Create Trial and Error Data View
set(0,'CurrentFigure',data_fig);
makebutton([5 5 100 20],@(varargin)rsmdemo('analyze',figlist),'','Analyze');

uicontrol(data_fig,'Style','Popup','String',...
          'Plot|Hydrogen vs. Rate|n-Pentane vs. Rate|Isopentane vs. Rate',...
          'Units','pixels','Position',[120 5 140 20],'BackgroundColor','w',...
          'CallBack',@(varargin)rsmdemo('plot1',figlist),'Tag','popup1');

set(data_fig,'DeleteFcn',@(varargin)rsmdemo('close',figlist));
set(data_fig,'Color',grey,'Name','Trial and Error Data','Tag','data1','Resize','off');
data_axes = axes;
set(data_axes,'Units','pixels','Position',[0 0 300 210],...
    'Visible','off','Xlim',[1 300],'Ylim',[1 200]);   
z = [2 50 110 170 230];
h = zeros(5,1);
colheads = {'Run #','Hydrogen','n-Pentane','Isopentane','Reaction Rate'};
for k = 1:5
  h(k)=text(z(k),182,colheads{k});
  set(h(k),'FontName','Geneva','FontSize',fs);
  set(h(k),'Color','k');
end

% Create Designed Experiment Data View
set(doe_fig,'Color',grey,'Name','Experimental Data','Tag','data2','Resize','off');
set(0,'CurrentFigure',doe_fig);
set(doe_fig,'DeleteFcn',@(varargin)rsmdemo('close',figlist));
makebutton([5 188 150 20],@(varargin)rsmdemo('doe',figlist),'doe_button','Do Experiment');
makebutton([5 5 110 20],@(varargin)rsmdemo('fit1',figlist),'','Response Surface');
makebutton([120 5 110 20],@(varargin)rsmdemo('fit2',figlist),'','Nonlinear Model');

uicontrol(doe_fig,'Style','Popup','String',...
          'Plot|Hydrogen vs. Rate|n-Pentane vs. Rate|Isopentane vs. Rate',...
          'Units','pixels','Position',[235 5 120 20],'BackgroundColor','w',...
          'CallBack',@(varargin)rsmdemo('plot2',figlist),'Tag','popup2');

doe_axes = axes;
set(doe_axes,'Units','pixels','Position',[1 1 300 210],'Visible','off',...
             'Xlim',[1 300],'Ylim',[1 200]);   
z = [2 50 110 170 230];
h = zeros(5,1);
for k = 1:5
  h(k)=text(z(k),165,colheads{k});
  set(h(k),'FontName','Geneva','FontSize',fs);
  set(h(k),'Color','k');
end

set(doe_fig,'Visible','on','HandleVisibility','callback')
set(data_fig,'Visible','on','HandleVisibility','callback')
set(fact_fig,'Visible','on','UserData',0,'HandleVisibility','callback')
% Bring Up Help Screen
showrsmdemohelp;
figure(fact_fig);
% Initialization Complete

% Callback for Hydrogen Slider
elseif strcmp(action,'setp1slider')
  p1 = get(p1slider,'Value');
  set(p1field,'String',num2str(p1));

% Callback for n-Pentane Slider
elseif strcmp(action,'setp2slider')
  p2 = get(p2slider,'Value');
  set(p2field,'String',num2str(p2));

% Callback for Isopentane Slider
elseif strcmp(action,'setp3slider')
  p3 = get(p3slider,'Value');
  set(p3field,'String',num2str(p3));

% Callback for Hydrogen Data Entry Field
elseif strcmp(action,'setp1field')
   p1 = str2double(get(p1field,'String'));
   if p1 > get(p1slider,'Max') || p1 < get(p1slider,'Min')
      p1max = get(p1slider,'Max');
      p1min = get(p1slider,'Min');
      s = ['You can only set this value between ' num2str(p1min) ' and ' num2str(p1max) '.'];
      warndlg(s);
      p1 = get(p1slider,'Value');
      set(p1field,'String',num2str(p1));
   else
      set(p1slider,'Value',p1);
   end
   
% Callback for n-Pentane Data Entry Field
elseif strcmp(action,'setp2field')
   p2 = str2double(get(p2field,'String'));
   if p2 > get(p2slider,'Max') || p2 < get(p2slider,'Min')
      p2max = get(p2slider,'Max');
      p2min = get(p2slider,'Min');
      s = ['You can only set this value between ' num2str(p2min) ' and ' num2str(p2max) '.'];
      warndlg(s);
      p2 = get(p2slider,'Value');
      set(p2field,'String',num2str(p2));
   else
      set(p2slider,'Value',p2);
   end
   
% Callback for Isopentane Data Entry Field
elseif strcmp(action,'setp3field')
   p3 = str2double(get(p3field,'String'));
   if p3 > get(p3slider,'Max') || p3 < get(p3slider,'Min')
      p3max = get(p3slider,'Max');
      p3min = get(p3slider,'Min');
      s = ['You can only set this value between ' num2str(p3min) ' and ' num2str(p3max) '.'];
      warndlg(s);
      p3 = get(p3slider,'Value');
      set(p3field,'String',num2str(p3));
   else
      set(p3slider,'Value',p3);
   end
   
% Callback for Run Button
elseif strcmp(action,'run')
   if isempty(data_fig)
       % Create No Data Figure Dialog.
       warndlg('The data figure is gone. Restart rsmdemo to run more tests.');
       return;
   end
   
   data = get(data_fig,'UserData');
   [m,n] = size(data);
   if m >= 12
       % Create Reset Button Dialog.
       warndlg('Press the Reset button to get another 13 runs');
       set(reset_btn,'Visible','on');
   end
   if m == 13
       set(run_btn,'Enable','off');
       return;
   end
   set(runs_field,'String',num2str(13-m-1));
   p1 = get(p1slider,'Value');
   p2 = get(p2slider,'Value');
   p3 = get(p3slider,'Value');
   y  = 1.25*(p2 - p3/1.5183)./(1+0.064*p1+0.0378*p2+0.1326*p3)*normrnd(1,0.05);
   set(out_field,'String',num2str(y));
   data = [data;p1 p2 p3 y];
   set(data_fig,'UserData',data);
   set(0,'CurrentFigure',data_fig);
   z = [24 90 155 215 285];
   x = 180 - 10*(m+1);
   row = [m+1 p1 p2 p3 y];
   for k = 1:5
       if k < 5,
          h(k) = text(z(k),x,sprintf('%4i',round(row(k))));
          set(h(k),'HorizontalAlignment','right');
          set(h(k),'FontName','Geneva','FontSize',fs);
       else
          h(k) = text(z(k),x,sprintf('%6.2f',row(k)));
          set(h(k),'HorizontalAlignment','right');
          set(h(k),'FontName','Geneva','FontSize',fs);
       end

      set(h(k),'Color','k');
   end
   set(0,'CurrentFigure',fact_fig);

% Callback for Do Experiment Button
elseif strcmp(action,'doe')
   % Do Designed Experiment.  
   data = get(doe_fig,'UserData');
   if ~isempty(data),
      doe_axes = get(doe_fig,'CurrentAxes');
      txt = findobj(doe_axes,'Type','text');
      delete(txt(1:end-5));
   end

   settings = cordexch(3,13,'q');
   mr = [285 190 65];
   mr = mr(ones(13,1),:);

   hr = [185 110 55];
   hr = hr(ones(13,1),:);
   settings = settings.*hr + mr;
   y = zeros(13,1);
   p1 = settings(:,1);
   p2 = settings(:,2);
   p3 = settings(:,3);
   z = [24 90 155 215 285];
   for k = 1:13
     x = 160 - 10*k;
     row = [k p1(k) p2(k) p3(k) y(k)];
     for k1 = 1:4
        set(0,'CurrentFigure',doe_fig);
        h(k1) = text(z(k1),x,sprintf('%4i',round(row(k1))));
        set(h(k1),'HorizontalAlignment','right');  
        set(h(k1),'FontName','Geneva','FontSize',fs);
        set(h(k1),'Color','k');
     end
     figure(fact_fig);
	 pause(0.5);
     set(p1slider,'Value',p1(k));
     set(p1field,'String',num2str(p1(k)));

     set(p2slider,'Value',p2(k));
     set(p2field,'String',num2str(p2(k)));

     set(p3slider,'Value',p3(k));
     set(p3field,'String',num2str(p3(k)));

     y(k)  = 1.25*(p2(k) - p3(k)/1.5183)./(1+0.064*p1(k)+0.0378*p2(k)+0.1326*p3(k))*normrnd(1,0.05);
     set(out_field,'String',num2str(y(k)));
     set(doe_fig,'UserData',data);
     set(0,'CurrentFigure',doe_fig);
     x = 160 - 10*k;
     row = [k p1(k) p2(k) p3(k) y(k)];
     h(5) = text(z(5),x,sprintf('%6.2f',row(5)));
     set(h(5),'HorizontalAlignment','right');
     set(h(5),'FontName','Geneva','FontSize',fs);
     set(h(5),'Color','k');
     pause(1);
     set(runs_field,'String',num2str(13-k));   
   end
   data = [settings y];
   set(doe_fig,'UserData',data);
   set(reset_btn,'Visible','on');
   set(run_btn,'Enable','off');

% Callback for Analyze Button
elseif strcmp(action,'analyze')
      data = get(data_fig,'UserData');
   
      if size(data,1) < 6
       % Create Not Enough Data Dialog.
       warndlg('Not enough data. Please do more test reactions.');
       return;
     end
      x = data(:,1:3);
      y = data(:,4);
      xname = {'Hydrogen','n-Pentane','Isopentane'};
      yname = 'Reaction Rate';
      try
         rstool(x,y,[],[],xname,yname);
      catch ME
         warndlg(sprintf('Error encountered trying to fit model:\n     %s\n%s',...
                  ME.message,...
                  'Try more reactions with different parameter values.'));
      end

% Callback for Trial and Error Figure Plot Menu
elseif strcmp(action,'plot1')
      data = get(data_fig,'UserData');
      if size(data,1) < 2
         % Create Not Enough Data Dialog.
         warndlg('Not enough data. Please do more test reactions.');
         return;
      end
      if get(p1_popup,'Value') == 2
         figure,
         plot(data(:,1),data(:,4),'+');
         if any(diff(sort(data(:,1)))) > 0
            lsline;
         end
         xlabel('Hydrogen');
         ylabel('Rate');
      elseif get(p1_popup,'Value') == 3
         figure,
         plot(data(:,2),data(:,4),'+');
         if any(diff(sort(data(:,2)))) > 0
            lsline;
         end
         xlabel('n-Pentane');
         ylabel('Rate');
      elseif get(p1_popup,'Value') == 4
         figure,
         plot(data(:,3),data(:,4),'+');
         if any(diff(sort(data(:,3)))) > 0
            lsline;
         end
         xlabel('Isopentane');
         ylabel('Rate');
      else
         return;
      end
      set(p1_popup,'Value',1);     

% Callback for DOE Figure Plot Menu
elseif strcmp(action,'plot2')
      data = get(doe_fig,'UserData');
      if size(data,1) < 1
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
     if get(p2_popup,'Value') == 2
        figure,
        plot(data(:,1),data(:,4),'+');
        lsline;
        xlabel('Hydrogen');
        ylabel('Rate');
     elseif get(p2_popup,'Value') == 3
        figure,
        plot(data(:,2),data(:,4),'+');
        lsline;
        xlabel('n-Pentane');
        ylabel('Rate');
     elseif get(p2_popup,'Value') == 4
        figure,
        plot(data(:,3),data(:,4),'+');
        lsline;
        xlabel('Isopentane');
        ylabel('Rate');
     else
        return;
     end
     set(p2_popup,'Value',1);     

% Callback for Response Surface Button 
elseif strcmp(action,'fit1')
      data = get(doe_fig,'UserData');
   
      if size(data,1) < 1
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
   
      x = data(:,1:3);
      y = data(:,4);
      xname = {'Hydrogen','n-Pentane','Isopentane'};
      yname = 'Reaction Rate';
      rstool(x,y,'quadratic',[],xname,yname);

% Callback for Nonlinear Model Button 
elseif strcmp(action,'fit2')
      data = get(doe_fig,'UserData');
      if size(data,1) < 6
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
   
      x = data(:,1:3);
      y = data(:,4);
      xname = {'Hydrogen','n-Pentane','Isopentane'};
      yname = 'Reaction Rate';
      beta0 = [1.2 0.1 0.01 0.1 1.5];
      nlintool(x,y,'hougen',beta0,0.05,xname,yname);

% Callback for Help Button 
elseif strcmp(action,'help')
   showrsmdemohelp;

% Callback for Close Button 
elseif strcmp(action,'close')
   if ishghandle(fact_fig), delete(fact_fig); end
   if ishghandle(data_fig), delete(data_fig); end
   if ishghandle(doe_fig),  delete(doe_fig);  end
 
% Callback for Reset Button 
elseif strcmp(action,'reset')
   set(run_btn,'Enable','on');
   data_axes = get(data_fig,'CurrentAxes');
   t = get(data_axes,'Children');
   
   delete(t(1:length(t)-5));
   set(runs_field,'String',num2str(13));
   set(reset_btn,'Visible','off');
   set(data_fig,'Userdata',[]);
   
% Callback for Export Button 
elseif strcmp(action,'output')
   if isempty(data_fig)
      warndlg('The data is gone. Restart rsmdemo to generate more data.');
      return;
   end
   data1 = get(data_fig,'UserData');

   if ~isempty(doe_fig)
      data2 = get(doe_fig,'UserData');
   else
      data2 = [];
   end

   if isempty(data1) && isempty(data2),
      warndlg('There is no data. Please do some test reactions.');
      return;
   elseif ~isempty(data1) && isempty(data2)
      x1 = data1(:,1:3);
      y1 = data1(:,4);
      labels = {'Trial and error reactants', 'Trial and error rate'};
      items = {x1, y1};
      varnames = {'trial_reactants', 'trial_rate'};
   elseif isempty(data1) && ~isempty(data2)
      x2 = data2(:,1:3);
      y2 = data2(:,4);
      labels = {'Experimental design reactants', 'Experimental design rate'};
      items = {x2, y2};
      varnames = {'doe_reactants', 'doe_rate'};
   elseif ~isempty(data1) && ~isempty(data2)
      x1 = data1(:,1:3);
      y1 = data1(:,4);
      x2 = data2(:,1:3);
      y2 = data2(:,4);
      items = {x1, y1, x2, y2};
      labels = {'Trial and error reactants', 'Trial and error rate', ...
                'Experimental design reactants', 'Experimental design rate'};
      varnames = {'trial_reactants', 'trial_rate','doe_reactants', 'doe_rate'};
   end
   export2wsdlg(labels, varnames, items, 'Export to Workspace');
end

% -------------------
function showrsmdemohelp
mapfilename = [docroot '/toolbox/stats/stats.map'];
helpview(mapfilename, 'rsmdemo_ref');

% -------------------
function h=makebutton(pos,callback,tag,string,vis)
% Make a button, and be sure it is big enough
if nargin<5
    vis = 'on';
end
h = uicontrol('Style','Pushbutton','Units','pixels','Position',pos,...
    'Callback',callback,'Tag',tag,'String',string,...
    'Visible',vis);
e = get(h,'Extent');
if any(e(3:4)>pos(3:4))
    pos(3:4) = max(pos(3:4),e(3:4));
    set(h,'Position',pos)
end
