function disttool(action,flag)
%DISTTOOL Demonstration of many probability distributions.
%   DISTTOOL creates interactive plots of probability distributions.
%   This is a demo that displays a plot of the cdf or pdf of
%   the distributions in the Statistics Toolbox.
%
%   Use popup menus to change the distribution (Normal to Binomial) or
%   the function (cdf to pdf). 
%
%   You can change the parameters of the distribution by typing
%   a new value or by moving a slider.    
%
%   You can interactively calculate new values by dragging a reference 
%   line across the plot.
%
%   Call DISTTOOL without arguments.
   
%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:41:21 $

if nargin < 1
    action = 'start';
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')   
   if isempty(gcbf)
      % Called directly, not as callback, with an input argument
      error('stats:disttool:BadInput','Invalid input argument to disttool');
   end
      
   childList = allchild(0);
   distfig = childList(childList == gcbf);
   ud = get(distfig,'Userdata');
   if isempty(ud) && strcmp(action,'motion')
      return
   end
  
   iscdf = 2 - get(ud.functionpopup,'Value');
   newx = str2double(get(ud.xfield,'string'));
   newy = str2double(get(ud.yfield,'string'));

   switch action,
      case 'motion',
          ud = mousemotion(ud,flag,newx,newy);
      case 'down',
          ud = mousedown(ud,flag);
      case 'up',
          mouseup;
      case 'setpfield',
          ud = setpfield(flag,ud,newx);
      case 'setpslider',
          ud = setpslider(flag,ud,newx);
      case 'setphi',
          ud = setphi(flag,ud,newx);
      case 'setplo',
          ud = setplo(flag,ud,newx);
      case 'changedistribution',
          ud = changedistribution(iscdf,ud);
      case 'changefunction',
          ud = changefunction(iscdf,ud,newx);
      case 'editx',
          ud = editx(ud);
      case 'edity',
          ud = edity(ud);
   end
end

% Initialize all GUI objects. Plot Normal CDF with sliders for parameters.
if strcmp(action,'start'),
   % Set positions of graphic objects
   axisp   = [.23 .35 .75 .55];
   pos = cell(7,3);
   pos{6,1} = [.15 .155 .07 .06];   % upper bound label
   pos{5,1} = [.14 .075 .08 .05];   % text
   pos{7,1} = [.15 .015 .07 .06];   % lower bound label
   pos{2,1} = [.23 .155 .10 .05];   % upper bounds
   pos{1,1} = [.23 .085 .10 .05];   % parameter
   pos{3,1} = [.23 .015 .10 .05];   % lower bounds
   pos{4,1} = [.34 .015 .03 .19];   % slider
   
   pos{6,2} = [.455 .155 .07 .06];   % upper bound label
   pos{5,2} = [.445 .075 .08 .05];   % text
   pos{7,2} = [.455 .015 .07 .06];   % lower bound label
   pos{2,2} = [.535 .155 .10 .05];   % upper bound
   pos{1,2} = [.535 .085 .10 .05];   % parameter
   pos{3,2} = [.535 .015 .10 .05];   % lower bound
   pos{4,2} = [.645 .015 .03 .19];   % slider
   
   pos{6,3} = [.76 .155 .07 .06];   % upper bound label
   pos{5,3} = [.75 .075 .08 .05];   % text
   pos{7,3} = [.76 .015 .07 .06];   % lower bound label
   pos{2,3} = [.84 .155 .10 .05];   % upper bound
   pos{1,3} = [.84 .085 .10 .05];   % parameter
   pos{3,3} = [.84 .015 .10 .05];   % lower bound
   pos{4,3} = [.95 .015 .03 .19];   % slider

   xfieldp = [.54 .245 .13 .05];
   xlabelp = [.50 .235 .04 .05];
   yfieldp = [0.04 .62 .13 .05];


   ud.dists = statguidists;
   dfltDist = find(strcmp('Normal',{ud.dists.name}));

   % Set axis limits and data
   [xrange, xvalues] = getxdata(true,dfltDist,ud);
   newx  = mean(xrange);
   yrange   = [0 1.1];
   pval = num2cell(ud.dists(dfltDist).parameters);
   yvalues = cdf(ud.dists(dfltDist).name,xvalues,pval{:});
   newy = cdf(ud.dists(dfltDist).name,newx,pval{:});

   %   Create Cumulative Distribution Plot
   ud.dist_fig = figure('Tag','distfig',...
                        'NumberTitle','off','IntegerHandle','off',...
                        'Name','Probability Distribution Function Tool');
   set(ud.dist_fig,'Units','Normalized','InvertHardcopy','on',...
        'PaperPositionMode','auto');
   figcolor = get(ud.dist_fig,'Color');
   if isunix  % default unix size is a little small
        unixpos = get(ud.dist_fig, 'Position');
        newheight = .49;
        hdif = newheight - unixpos(4);
        unixpos(2) = unixpos(2) - hdif;
        unixpos(3) = .4865;
        unixpos(4) = newheight;
        set(ud.dist_fig, 'Position', unixpos);
   end

   % Brushing and linking don't work, so remove them to avoid confusion
   delete(uigettool(ud.dist_fig,'Exploration.Brushing'))
   delete(uigettool(ud.dist_fig,'DataManager.Linking'))
   delete(findall(ud.dist_fig,'Tag','figDataManagerBrushTools'))
   delete(findall(ud.dist_fig,'Tag','figBrush'))
   delete(findall(ud.dist_fig,'Tag','figLinked'))
   
   dist_axes = axes;
   set(dist_axes,'NextPlot','add',...
      'Position',axisp,'XLim',xrange,'YLim',yrange,'Box','on','Tag','distaxes');
   ud.dline = plot(xvalues,yvalues,'b-','LineWidth',2,'Tag','dline');

% Define graphics objects
   for idx = 1:3
       nstr = int2str(idx);
       ud.pfhndl(idx) = uicontrol('Style','edit','Units','normalized',...
           'Position',pos{1,idx},...
           'String',num2str(ud.dists(dfltDist).parameters(2-rem(idx,2))),...
           'BackgroundColor','white',...
           'CallBack',['disttool(''setpfield'',',nstr,')'],...
           'Tag',['pfhndl' num2str(idx)]);
         
       ud.hihndl(idx) = uicontrol('Style','edit','Units','normalized',...
           'Position',pos{2,idx},...
           'String',num2str(ud.dists(dfltDist).phi(2-rem(idx,2))),...
           'BackgroundColor','white',...
           'CallBack',['disttool(''setphi'',',nstr,')'],...
           'Tag',['hihndl' num2str(idx)]);
         
       ud.lohndl(idx) = uicontrol('Style','edit','Units','normalized',...
           'Position',pos{3,idx},...
           'String',num2str(ud.dists(dfltDist).plo(2-rem(idx,2))),...
           'BackgroundColor','white',... 
           'CallBack',['disttool(''setplo'',',nstr,')'],...
           'Tag',['lohndl' num2str(idx)]);

       ud.pslider(idx) = uicontrol('Style','slider','Units','normalized',...
           'Position',pos{4,idx},...
           'Value',ud.dists(dfltDist).parameters(2-rem(idx,2)),...
           'Max',ud.dists(dfltDist).phi(2-rem(idx,2)),...
           'Min',ud.dists(dfltDist).plo(2-rem(idx,2)),...
           'Callback',['disttool(''setpslider'',',nstr,')'],...
           'Tag',['pslider' num2str(idx)]);

       ud.ptext(idx) = uicontrol('Style','text','Units','normalized',...
           'Position',pos{5,idx},...
           'ForegroundColor','k','BackgroundColor',figcolor,...
           'String',ud.dists(dfltDist).paramnames{2-rem(idx,2)},...
           'Tag',['ptext' num2str(idx)]); 
   
       ud.lowerboundtext(idx) = uicontrol('Style','text','Units','normalized',...
         'Position', pos{7,idx},'ForegroundColor','k',...
         'BackgroundColor',figcolor,'String', 'Lower bound',...
         'Tag',['lowerboundtext' num2str(idx)]); 
   
       ud.upperboundtext(idx) = uicontrol('Style','text','Units','normalized',...
         'Position', pos{6,idx},'ForegroundColor','k',...
         'BackgroundColor',figcolor,'String', 'Upper bound',...
         'Tag',['upperboundtext' num2str(idx)]); 
   end      

   enableParams(ud, 3, 'off');

   ud.yaxistext=uicontrol('Style','Text','Units','normalized',...
       'Position',yfieldp + [0 0.05 0 -0.01],...
       'ForegroundColor','k','BackgroundColor',figcolor,...
       'String','Probability:','Tag','yaxistext'); 
		
   ud.distribution=uicontrol('Style','Text','String','Distribution:',...
       'ForegroundColor','k','BackgroundColor',figcolor,...
       'Units','normalized','Visible','off','Tag','distribution');
   dist_extent =  get(ud.distribution, 'extent');
   xpos = .23;
   temp_pos = [xpos .915 dist_extent(3) .06];
   set(ud.distribution, 'Position', temp_pos, 'Visible', 'on');
   xpos = xpos + dist_extent(3) + .01;
        
   distNameList = {ud.dists.name};
   ud.popup=uicontrol('Style','Popup','String',distNameList,...
        'Units','normalized','Position',[xpos .92 .25 .06],...
        'UserData','popup','Value',dfltDist,'BackgroundColor','w',...
        'CallBack','disttool(''changedistribution'')','Tag','popup');
        
   ud.type=uicontrol('Style', 'Text', 'String', 'Function type:', ...
                     'ForegroundColor','k','BackgroundColor',figcolor,...
                     'Units','normalized', 'Visible', 'off','Tag','type');
   type_extent = get(ud.type, 'extent');
   xpos = xpos + .25 + .03;
   temp_pos = [xpos, .915, type_extent(3), .06];
   set(ud.type, 'Position', temp_pos, 'Visible', 'on');
        
   xpos = xpos + type_extent(3) + .01;
   ud.functionpopup=uicontrol('Style','Popup','String',...
        {'CDF' 'PDF'},'Value',1,'Units','normalized',...
        'Position',[xpos .92 .15 .06],'BackgroundColor','w',...
        'CallBack','disttool(''changefunction'')','Tag','functionpopup');
        
   ud.Xlabel=uicontrol('Style', 'Text', 'String', 'X:', ...
                             'ForegroundColor','k','BackgroundColor',figcolor,...
                             'Units','normalized', 'Position', xlabelp,...
                             'Tag','Xlabel');     
        
   ud.xfield=uicontrol('Style','edit','Units','normalized','Position',xfieldp,...
         'String',num2str(newx),'BackgroundColor','white',...
         'CallBack','disttool(''editx'')','UserData',newx,'Tag','xfield');
         
   ud.yfield=uicontrol('Style','edit','Units','normalized','Position',yfieldp,...
         'BackgroundColor','white','String',num2str(newy),...
		 'UserData',newy,'CallBack','disttool(''edity'')','Tag','yfield');

   % Create Reference Lines
   ud.vline = plot([0 0],yrange,'r-.','Tag','vline');
   ud.hline = plot(xrange,[0.5 0.5],'r-.','Tag','hline');

   set(ud.vline,'ButtonDownFcn','disttool(''down'',1)');
   set(ud.hline,'ButtonDownFcn','disttool(''down'',2)');

   set(ud.dist_fig,...
       'WindowButtonMotionFcn','disttool(''motion'',0)',...
      'WindowButtonDownFcn','disttool(''down'',1)',...
      'Userdata',ud,'HandleVisibility','callback');
end % End of initialization.

set(ud.dist_fig,'UserData',ud);
% END OF disttool MAIN FUNCTION.

% BEGIN HELPER FUNCTIONS.

%-----------------------------------------------------------------------------
% Update graphic objects in GUI. UPDATEGUI
function ud = updategui(ud,xvalues,yvalues,xrange,yrange,newx,newy)

if isempty(xrange)
   xrange = get(gcba,'Xlim');
end
if isempty(yrange)
   yrange = get(gcba,'Ylim');
end
if ~isempty(xvalues) && ~isempty(yvalues)
   set(ud.dline,'XData',xvalues,'Ydata',yvalues,'Color','b');
   xrange(2) = max(max(xvalues), xrange(2));
   xrange(1) = min(min(xvalues), xrange(1));
   set(gcba,'Xlim',xrange)
   set(ud.hline,'Xdata',xrange)
end
if ~isempty(newy), 
    set(ud.yfield,'String',num2str(newy),'UserData',newy); 
    set(ud.hline,'XData',xrange,'YData',[newy newy]);
end
if ~isempty(newx), 
    set(ud.xfield,'String',num2str(newx),'UserData',newx); 
    set(ud.vline,'XData',[newx newx],'YData',yrange);
end


%-----------------------------------------------------------------------------
% Calculate new probability or density given a new "X" value. GETNEWY
function newy = getnewy(newx,ud)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
name = ud.dists(popupvalue).name;
if strcmpi(name,'weibull')  % use new name to avoid warning
   name = 'wbl';
end

pval = num2cell(ud.dists(popupvalue).parameters);
if iscdf
   newy = cdf(name,newx,pval{:});
else
   newy = pdf(name,newx,pval{:});
end


%-----------------------------------------------------------------------------
% Supply x-axis range and x data values for each distribution. GETXDATA
function [xrange, xvalues] = getxdata(iscdf,popupvalue,ud)
phi = ud.dists(popupvalue).phi;
plo = ud.dists(popupvalue).plo;
parameters = ud.dists(popupvalue).parameters;
switch ud.dists(popupvalue).rvname
    case 'betarv', % Beta 
       xrange  = [0 1];
       xvalues = 0.001:0.001:0.999;
    case 'binorv', % Binomial 
       xrange  = [-0.5 phi(1)+0.5];
       xvalues = 0:phi(1);
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
	case 'chi2rv', % Chi-square
       xrange  = [0 phi + 4 * sqrt(2 * phi)];
       xvalues = linspace(0,xrange(2),1001);
    case 'unidrv', % Discrete Uniform
       xrange  = [-0.5 phi+0.5];
       xvalues = 0:phi;
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 'exprv', % Exponential
       xrange  = [0 4*phi];
       xvalues = 0:0.1*parameters:4*phi;
    case 'evrv', % Extreme Value
       xrange = [plo(1)-5*phi(2), phi(1)+2*phi(2)];
       xvalues = linspace(xrange(1),xrange(2),1001);
    case 'frv', % F 
       xrange  = [0 finv(0.995,plo(1),plo(1))];
       xvalues = linspace(xrange(1),xrange(2),1001);
    case 'gamrv', % Gamma
       hixvalue = phi(1) * phi(2) + 4*sqrt(phi(1) * phi(2) * phi(2));
       xrange  = [0 hixvalue];
       xvalues = linspace(0,hixvalue,1001);
    case 'gevrv', % Generalized Extreme Value
       loxvalue = gevinv(0.01,plo(1),phi(2),plo(3));
       hixvalue = gevinv(0.99,phi(1),phi(2),phi(3));
       xrange  = [loxvalue hixvalue];       
       xvalues = linspace(loxvalue,hixvalue,1001);
    case 'gprv', % Generalized Pareto
       hixvalue = gpinv(0.99,phi(1),phi(2),phi(3));
       xrange  = [plo(3) hixvalue];       
       % a fine grid to make sure we get close to the mode at theta for any theta
       xvalues = linspace(plo(3),hixvalue,5001);
    case 'georv', % Geometric
       hixvalue = geoinv(0.99,plo(1));
       xrange  = [-0.5 hixvalue+0.5];       
       xvalues = 0:round(hixvalue);
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 'hygerv', % Hypergeometric
       xrange  = [-0.5 phi(1)+0.5];
       xvalues = 0:phi(1);
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 'lognrv', % Lognormal
       xrange = [0 logninv(0.99,phi(1),phi(2))];
       xvalues = linspace(0,xrange(2),1001);
    case 'nbinrv', % Negative Binomial
       xrange = [-0.5 nbininv(0.99,phi(1),plo(2))+0.5];
       xvalues = 0:xrange(2);
       if iscdf,
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 'ncfrv', % Noncentral F
       xrange = [0 phi(3)+30];
       xvalues = linspace(sqrt(eps),xrange(2),1001);
    case 'nctrv', % Noncentral T
       xrange = [phi(2)-14 phi(2)+14];
       xvalues = linspace(xrange(1),xrange(2),1001);
    case 'ncx2rv', % Noncentral Chi-square
       xrange = [0 phi(2)+30];
       xvalues = linspace(sqrt(eps),xrange(2),1001);
    case 'normrv', % Normal
       xrange   = [plo(1) - 3 * phi(2) phi(1) + 3 * phi(2)];
       xvalues  = linspace(plo(1)-3*phi(2), phi(1)+3*phi(2), 1001);
    case 'poissrv', % Poisson
      xrange  = [-0.5 4*phi(1)+0.5];
      xvalues = 0:round(4*parameters(1));
      if iscdf
         xvalues = [xvalues - sqrt(eps);xvalues];
         xvalues = xvalues(:)';
      end
    case 'raylrv', % Rayleigh
       xrange = [0 raylinv(0.995,phi(1))];
       xvalues = linspace(xrange(1),xrange(2),1001);
    case 'trv', % T
       lowxvalue = tinv(0.005,plo(1));
       xrange  = [lowxvalue -lowxvalue];
       xvalues = linspace(xrange(1),xrange(2),1001);
    case 'unifrv', % Uniform
       xrange  = [plo(1) phi(2)];
       if iscdf
          xvalues = [plo(1) ...
                     parameters(1)-eps*abs(parameters(1)) ...
                     parameters(1)+eps*abs(parameters(1)) ...
                     parameters(2)-eps*abs(parameters(2)) ...
                     parameters(2)+eps*abs(parameters(2)) ...
                     phi(2)];
       else
          xvalues = [parameters(1)+eps*abs(parameters(1)) ...
                     parameters(2)-eps*abs(parameters(2))];
       end
    case 'weibrv', % Weibull
       xrange  = [0 wblinv(0.995,plo(1),plo(2))];
       xvalues = linspace(xrange(1),xrange(2),1001);
end


%------------------------------------------------------------------------------
function h = gcba
h = get(gcbf,'CurrentAxes');


%------------------------------------------------------------------------------
% Enable or disable parameters, upper and lower bounds and sliders
function enableParams(ud, p, state)
if strcmp(state, 'off')
    color =  [0.831373 0.815686 0.784314];
    set(ud.pfhndl(p),'String', '');
    set(ud.hihndl(p),'String', '');
    set(ud.lohndl(p),'String', '');
    set(ud.ptext(p),'String', '');
else
    color = 'white';
end
set(ud.pfhndl(p),'Enable', state, 'Backgroundcolor', color);
set(ud.hihndl(p),'Enable', state, 'Backgroundcolor', color);
set(ud.lohndl(p),'Enable',state, 'Backgroundcolor', color);
set(ud.pslider(p),'Enable', state);
set(ud.ptext(p),'Enable',state);
set(ud.lowerboundtext(p),'Enable',state);
set(ud.upperboundtext(p),'Enable',state);


%------------------------------------------------------------------------------
% set sliders to use integer or continuous values as appropriate
function setsliderstep(pslider, intparam)
ss = [0.01 0.1];       % MATLAB default
if (intparam) && strcmp(get(pslider, 'Enable'), 'on')
   d = max(1, get(pslider,'Max') - get(pslider,'Min'));

   ss = max(1, round(ss * d));
   if (ss(2) <= ss(1)), ss(2) = ss(1) + 1; end
   ss = ss ./ d;
end
set(pslider, 'SliderStep', ss);


%-----------------------------------------------------------------------------
% Determine validity of value with respect to min and max
function valid = okwithminmax(cv, pmin, pmax, popupvalue, fieldnum, ud)

if ~isreal(cv) || ~isreal(pmin) || ~isreal(pmax)
    valid = false;

% All parameters may be in the open interval (pmin, pmax)
elseif (pmin < cv) && (cv < pmax)
    valid = true;
    
else
    valid = false;
    rvname = ud.dists(popupvalue).rvname;
    paramname = lower(ud.dists(popupvalue).paramnames{fieldnum});
    
    % Binomial p may also be in the closed interval [pmin, pmax]
    if  (isequal(rvname, 'binorv') && isequal(paramname,'prob')) 
        if (pmin <= cv) &&  (cv <= pmax)
            valid = true;
        end
        
    % NC Chi-sq and F delta may also be in half-open interval [pmin, pmax)
    elseif  (isequal(rvname, 'ncx2rv') && isequal(paramname,'delta')) ...
         || (isequal(rvname, 'ncfrv')  && isequal(paramname,'delta'))
        if (pmin <= cv) &&  (cv < pmax)
            valid = true;
        end
        
    % Hypergeometric may also be in half-open interval [pmin, pmax)
    elseif  (isequal(rvname, 'hygerv') && ...
                (isequal(paramname,'k') || isequal(paramname,'n')))
        if (pmin <= cv) &&  (cv < pmax)
            valid = true;
        end

    end
end

%-----------------------------------------------------------------------------
% Check that new slider positions are legal
function ok = slidervaluesok(popupvalue, cv, fieldno, ud)
ok = true;

% For uniform, pvalue "max" must be greater than pvalue "min"
if isequal(ud.dists(popupvalue).rvname, 'unifrv')
    paramname = lower(ud.dists(popupvalue).paramnames{fieldno});
    if isequal(paramname, 'min')
        pv = ud.dists(popupvalue).parameters(2);
        if cv >= pv
            ok = false;
        end
    else %if isequal(paramname, 'max')
        pv = ud.dists(popupvalue).parameters(1);
        if cv <= pv
            ok = false;
        end
    end
end

% For hypergeometric, N and K must each be no more than M
if isequal(ud.dists(popupvalue).rvname, 'hygerv')
    paramname = lower(ud.dists(popupvalue).paramnames{fieldno});
    switch paramname
        case 'm',
            pv1 = ud.dists(popupvalue).parameters(2);
            pv2 = ud.dists(popupvalue).parameters(3);
            if cv < pv1 || cv < pv2
                ok = false;
            end
        case {'k','n'}
            pv = ud.dists(popupvalue).parameters(1);
            if cv > pv
                ok = false;
            end
    end
end

    
% END HELPER FUNCTIONS.

% BEGIN CALLBACK FUNCTIONS.

%-----------------------------------------------------------------------------
% Track a mouse moving in the GUI. MOUSEMOTION
function ud = mousemotion(ud,flag,newx,newy) 
popupvalue = get(ud.popup,'Value');
parameters = ud.dists(popupvalue).parameters;
name = ud.dists(popupvalue).name;
discrete = ud.dists(popupvalue).discrete;
xrange = get(gcba,'Xlim');
yrange = get(gcba,'Ylim');

if flag == 0,
    cursorstate = get(gcbf,'Pointer');
    cp = get(gcba,'CurrentPoint');
    cx = cp(1,1);
    cy = cp(1,2);
    fuzzx = 0.01 * (xrange(2) - xrange(1));
    fuzzy = 0.01 * (yrange(2) - yrange(1));
    online = cy > yrange(1) & cy < yrange(2) & cx > xrange(1) & cx < xrange(2) &...
           ((cy > newy - fuzzy & cy < newy + fuzzy) | (cx > newx - fuzzx & cx < newx + fuzzx));
    if online && strcmp(cursorstate,'arrow'),
         set(gcbf,'Pointer','crosshair');
    elseif ~online && strcmp(cursorstate,'crosshair'),
         set(gcbf,'Pointer','arrow');
    end
    
elseif flag == 1 || flag == 3
    cp = get(gcba,'CurrentPoint');
    if ~isinaxes(cp, gcba)
        if flag == 1
            set(gcbf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',3)');
        end
        return;
    elseif flag == 3
        set(gcbf,'Pointer','crosshair');
        set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',1)');
    end
        
    newx=cp(1,1);
    if discrete,
         newx = round(newx);
    end
    if newx > xrange(2)
         newx = xrange(2);
    end
    if newx < xrange(1)
         newx = xrange(1);
    end

    newy = getnewy(newx,ud);
	ud = updategui(ud,[],[],xrange,yrange,newx,newy);    

elseif flag == 2 || flag == 4
    
    cp = get(gcba,'CurrentPoint');
    if ~isinaxes(cp, gcba)
        if flag == 2
            set(gcbf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',4)');
        end
        return;
    elseif flag == 4
        set(gcbf,'Pointer','crosshair');
        set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',2)');
    end
        
    newy=cp(1,2);
    if newy > yrange(2)
        newy = yrange(2);
    end
    if newy < yrange(1)
        newy = yrange(1);
    end

    pval = num2cell(parameters);
    if strcmpi(name,'weibull')  % use new name to avoid warning
        name = 'wbl';
    end
    newx = icdf(name,newy,pval{:});
    ud = updategui(ud,[],[],xrange,yrange,newx,newy);
end


%----------------------------------------------------------------------------
% Callback for mousing down in the GUI. MOUSEDOWN
function ud = mousedown(ud,flag)
popupvalue = get(ud.popup,'Value');
discrete = ud.dists(popupvalue).discrete;

cp = get(gcba,'CurrentPoint');

if ~isinaxes(cp, gcba)
    return;
end

xrange = get(gcba,'Xlim');
yrange = get(gcba,'Ylim');
   
set(gcbf,'Pointer','crosshair');
newx=cp(1,1);
if discrete,
   newx = round(newx);
end
if newx > xrange(2)
   newx = xrange(2);
end
if newx < xrange(1)
   newx = xrange(1);
end
newy = getnewy(newx,ud);
    
ud = updategui(ud,[],[],xrange,yrange,newx,newy);
      
if flag == 1
   set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',1)');
elseif flag == 2
   set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',2)');
end
set(gcbf,'WindowButtonUpFcn','disttool(''up'')');


%-----------------------------------------------------------------------------
% Callback for mousing up in the GUI. MOUSEUP
function mouseup
set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',0)');
set(gcbf,'WindowButtonUpFcn','');


%-----------------------------------------------------------------------------
% Callback for editing x-axis text field. EDITX
function ud = editx(ud)
newx=str2double(get(ud.xfield,'String'));
if isnan(newx)
    newx = get(ud.xfield,'Userdata');
    set(ud.xfield,'String',num2str(newx));
    warndlg('Critical values must be numeric. Resetting to previous value.');
    return;
end
xrange = get(gcba,'Xlim');
if newx > xrange(2)
    newx = xrange(2);
    set(ud.xfield,'String',num2str(newx));
end
if newx < xrange(1)
    newx = xrange(1);
    set(ud.xfield,'String',num2str(newx));
end
newy = getnewy(newx,ud);
ud = updategui(ud,[],[],[],[],newx,newy);


%-----------------------------------------------------------------------------
% Callback for editing y-axis text field. EDITY
function ud = edity(ud)
popupvalue = get(ud.popup,'Value');
parameters = ud.dists(popupvalue).parameters;
name = ud.dists(popupvalue).name;
newy=str2double(get(ud.yfield,'String'));
if isnan(newy) 
   newy = get(ud.yfield,'Userdata');
   set(ud.yfield,'String',num2str(newy));
   warndlg('Probabilities must be numeric. Resetting to previous value.');
   return;
end

if newy > 1
    newy = 1;
    set(ud.yfield,'String',num2str(newy),'UserData',newy);
end
if newy < 0
    newy = 0;
    set(ud.yfield,'String',num2str(newy),'UserData',newy);
end
pval = num2cell(parameters);
if strcmpi(name,'weibull')  % use new name to avoid warning
   name = 'wbl';
end
newx = icdf(name,newy,pval{:});
ud = updategui(ud,[],[],[],[],newx,newy);


%-----------------------------------------------------------------------------
% Callback for changing probability distribution function. CHANGEDISTRIBUTION
function ud = changedistribution(iscdf,ud)
popupvalue = get(ud.popup,'Value');
%name       = ud.dists(popupvalue).name;
parameters = ud.dists(popupvalue).parameters;
paramnames = ud.dists(popupvalue).paramnames;
%pmax       = ud.dists(popupvalue).pmax;
%pmin       = ud.dists(popupvalue).pmin;
phi        = ud.dists(popupvalue).phi;
plo        = ud.dists(popupvalue).plo;
discrete   = ud.dists(popupvalue).discrete;
intparam   = ud.dists(popupvalue).intparam;

[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
set(gcba,'Xlim',xrange);
newx = mean(xrange);

nparams = length(parameters);
enableParams(ud, 1:nparams, 'on');
if nparams < 3
    enableParams(ud, (nparams+1):3, 'off');
end
    
set(ud.dline,'Marker','none','LineStyle','-');   
    
if iscdf,
    set(ud.hline,'Visible','on');
else
    set(ud.hline,'Visible','off');
    if discrete,
        set(ud.dline,'Marker','+','LineStyle','none');
    end
end
for idx = 1:nparams
    set(ud.ptext(idx),'String',paramnames{idx});
    set(ud.pfhndl(idx),'String',num2str(parameters(idx)));
    set(ud.lohndl(idx),'String',num2str(plo(idx)));
    set(ud.hihndl(idx),'String',num2str(phi(idx)));
    set(ud.pslider(idx),'Min',plo(idx),'Max',phi(idx),'Value',parameters(idx));
    setsliderstep(ud.pslider(idx),intparam(idx));
end

if iscdf,
   newy = getnewy(newx,ud);
   yvalues = getnewy(xvalues,ud);
   yrange = [0 1.1];
   ud = updategui(ud,xvalues,yvalues,[],yrange,newx,newy);
else
   ud = changefunction(iscdf,ud,newx);
end


%-----------------------------------------------------------------------------
% Toggle CDF/PDF or PDF/CDF. CHANGEFUNCTION 
function ud = changefunction(iscdf,ud,newx)
popupvalue = get(ud.popup,'Value');
name       = ud.dists(popupvalue).name;
parameters = ud.dists(popupvalue).parameters;
%pmax       = ud.dists(popupvalue).pmax;
%pmin       = ud.dists(popupvalue).pmin;
phi        = ud.dists(popupvalue).phi;
plo        = ud.dists(popupvalue).plo;
discrete   = ud.dists(popupvalue).discrete;
%intparam   = ud.dists(popupvalue).intparam;

if ~iscdf
  xrange = get(gcba,'Xlim'); 
  switch ud.dists(popupvalue).rvname
    case 'betarv', % Beta 
       tempx = [0.01 0.1:0.1:0.9 0.99];
       temp1 = linspace(plo(1),phi(1),21);
       temp2 = linspace(plo(2),phi(2),21);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf(name,x,p1,p2);
    case 'binorv', % Binomial 
       maxy = 1;
	case 'chi2rv', % Chi-square
       tempx = linspace(xrange(1),xrange(2),101);
       maxy = pdf(name,tempx,plo);
    case 'unidrv', % Discrete Uniform
       maxy = 1 ./ plo;
    case 'exprv', % Exponential
       maxy = 1 / plo;
    case 'evrv', % Extreme Value
       maxy = 1 / (exp(1) * plo(2));
    case 'frv', % F 
       tempx = linspace(xrange(1),xrange(2),101);
       temp1 = plo(1):phi(1);
       temp2 = plo(2):plo(2);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);                
       maxy = 1.05*pdf(name,x,p1,p2);
    case 'gamrv', % Gamma
       tempx = [0.1 linspace(xrange(1),xrange(2),101)];
       temp1 = linspace(plo(1),phi(1),11);
       temp2 = linspace(plo(2),phi(2),11);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf(name,x,p1,p2);
    case 'gevrv', % Generalized Extreme Value
       maxy = 1/(2*plo(2));
    case 'gprv', % Generalized Pareto
       maxy = 1/plo(2);
    case 'georv', % Geometric
       maxy = phi(1);
    case 'hygerv', % Hypergeometric
       maxy = 1;
    case 'lognrv', % Lognormal
       x = exp(linspace(plo(1),plo(1)+0.5*plo(2).^2));
       maxy = pdf(name,x,plo(1),plo(2));
    case 'nbinrv', % Negative Binomial
       maxy = 0.91;      
    case 'ncfrv', % Noncentral F
       maxy = 0.4;
    case 'nctrv', % Noncentral T
       maxy = 0.4;
    case 'ncx2rv', % Noncentral Chi-square
       maxy = 0.4;
    case 'normrv', % Normal
       maxy = pdf(name,0,0,plo(2));
    case 'poissrv', % Poisson
       maxy = pdf(name,[0 plo(1)],plo(1));
    case 'raylrv', % Rayleigh
       maxy = 0.6;  
    case 'trv', % T
       maxy = 0.4;  
    case 'unifrv', % Uniform
       maxy = 1 ./ (plo(2) - phi(1));
    case 'weibrv', % Weibull
       tempx = [0.05 linspace(xrange(1),xrange(2),21)];
       temp1 = linspace(plo(1),phi(1),21);
       temp2 = linspace(plo(2),phi(2),21);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf('wbl',x,p1,p2);
  end
  ymax = abs(1.1 .* nanmax(maxy(:)));
  if ~isempty(ymax) && ~isnan(ymax) && ~isinf(ymax)
      yrange = [0 abs(1.1 .* max(ymax(:)))];
  else
      yrange = [0 1.1];
  end
  set(gcba,'Ylim',yrange);
end
[xrange, xvalues] = getxdata(iscdf, popupvalue, ud);
nparams = length(parameters);
for idx = 1:nparams
    set(ud.pfhndl(idx),'String',num2str(parameters(idx)));
end  
if iscdf
    ud = changedistribution(iscdf,ud);
    set(ud.yaxistext,'String','Probability');
    set(ud.yfield,'Style','edit','BackgroundColor','white');
    set(ud.hline,'Visible','on');
    yrange = [0 1.1];
    set(gcba,'YLim',yrange);
    set(ud.dline,'LineStyle','-','Marker','none');
else
    set(ud.yaxistext,'String','Density');
    set(ud.yfield,'Style','text','BackgroundColor',[0.8 0.8 0.8]);
    set(ud.hline,'Visible','off');
    if discrete,
        set(ud.dline,'Marker','+','LineStyle','none');
    else
        set(ud.dline,'Marker','none','LineStyle','-');
    end
    newy = getnewy(newx,ud);
    yvalues = getnewy(xvalues,ud);
    ud = updategui(ud,xvalues,yvalues,xrange,yrange,newx,newy);
end


%-----------------------------------------------------------------------------
% Callback for controlling lower bound of the parameters using editable text boxes.
function ud = setplo(fieldno,ud,newx)

iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
intparam = ud.dists(popupvalue).intparam(fieldno);
fieldentry = get(ud.lohndl(fieldno),'String');
cv   = str2double(fieldentry);
pv   = str2double(get(ud.pfhndl(fieldno),'String'));
cmax = str2double(get(ud.hihndl(fieldno),'String'));

if intparam    
    cv = round(cv);
    set(ud.lohndl(fieldno),'String',num2str(cv));
end
badval = false;

% if the proposed lower limit is larger then the current upper limit, no good
if cv >= cmax
  badval = true;
  
% if the proposed lower limit is smaller than the current upper limit but
% larger then the current value, it must be ok, except for the cross check
% needed for some distributions
elseif cv > pv
  if slidervaluesok(popupvalue, cv, fieldno, ud)
      set(ud.pslider(fieldno),'Min',cv);
      ud.dists(popupvalue).plo(fieldno) = cv;
      set(ud.pfhndl(fieldno),'String',num2str(cv));
      ud = setpfield(fieldno,ud,newx);
  else
      badval = true;
  end
  
% else we need to check if it's larger then the minimum allowed value
else
  pmin = ud.dists(popupvalue).pmin(fieldno);
  pmax = ud.dists(popupvalue).pmax(fieldno);
  if okwithminmax(cv, pmin, pmax, popupvalue, fieldno, ud)
    set(ud.pslider(fieldno),'Min',cv);
    ud.dists(popupvalue).plo(fieldno) = cv;
  else
    badval = true;
  end
end
[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
yvalues = getnewy(xvalues,ud);
newy = getnewy(newx,ud);
setsliderstep(ud.pslider(fieldno),intparam);
ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy);

if badval
    preventry = num2str(ud.dists(popupvalue).plo(fieldno));
    wmsg = sprintf('Bad lower bound value "%s", resetting to "%s"', ...
                   fieldentry, preventry);
    uiwait(warndlg(wmsg, 'DISTTOOL', 'modal'))
    set(ud.lohndl(fieldno),'String',preventry);
end


%-----------------------------------------------------------------------------
% Callback for controlling upper bound of the parameters using editable text boxes.
function ud = setphi(fieldno,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
intparam = ud.dists(popupvalue).intparam(fieldno);
fieldentry = get(ud.hihndl(fieldno),'String');
cv   = str2double(fieldentry);
pv   = str2double(get(ud.pfhndl(fieldno),'String'));
cmin = str2double(get(ud.lohndl(fieldno),'String'));

if intparam
    cv = round(cv);
    set(ud.hihndl(fieldno),'String',num2str(cv));
end

badval = false;

% if the proposed upper limit is samller then the current lower limit, no good
if cv <= cmin
  badval = true;
  
% if the proposed upper limit is larger than the current lower limit but
% smaller then the current value, it must be ok, except for the cross check
% needed for some distributions
elseif cv < pv
  if slidervaluesok(popupvalue, cv, fieldno, ud)
      set(ud.pslider(fieldno),'Max',cv);
      ud.dists(popupvalue).phi(fieldno) = cv;
      set(ud.pfhndl(fieldno),'String',num2str(cv));
      ud = setpfield(fieldno,ud,newx);
  else
      badval = true;
  end
  
% else we need to check if it's smaller then the maximum allowed value
else
  pmin = ud.dists(popupvalue).pmin(fieldno);
  pmax = ud.dists(popupvalue).pmax(fieldno);
  if okwithminmax(cv, pmin, pmax, popupvalue, fieldno, ud)
    set(ud.pslider(fieldno),'Max',cv);
    ud.dists(popupvalue).phi(fieldno) = cv;
  else
    badval = true;
  end
end
[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
yvalues = getnewy(xvalues,ud);
newy = getnewy(newx,ud);
setsliderstep(ud.pslider(fieldno),intparam);
ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy);

if badval
    preventry = num2str(ud.dists(popupvalue).phi(fieldno));
    wmsg = sprintf('Bad upper bound value "%s", resetting to "%s"', ...
                   fieldentry, preventry);
    uiwait(warndlg(wmsg, 'DISTTOOL', 'modal'))
    set(ud.hihndl(fieldno),'String',preventry);
end


%-----------------------------------------------------------------------------
% Callback for controlling the parameter values using sliders.
function ud = setpslider(sliderno,ud,newx)

% turn off this callback in case we have to put up a warning dialog
cbstr = get(ud.pslider(sliderno),'Callback');
set(ud.pslider(sliderno),'Callback',[]);

iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
intparam = ud.dists(popupvalue).intparam(sliderno);

cv = get(ud.pslider(sliderno),'Value');
if intparam
    cv = round(cv);
end

% Set string value, then re-read in case of rounding
set(ud.pfhndl(sliderno),'String',num2str(cv));
cv = str2double(get(ud.pfhndl(sliderno),'String'));

if slidervaluesok(popupvalue, cv, sliderno, ud)
    ud.dists(popupvalue).parameters(sliderno) = cv;
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud); %#ok<ASGLU>
    yvalues = getnewy(xvalues,ud);
    newy = getnewy(newx,ud);
    ud = updategui(ud,xvalues,yvalues,[],[],newx,newy);
else % handle a conflict between parameters for certain distributions
    pv = ud.dists(popupvalue).parameters(sliderno);
    preventry = num2str(pv);
    wmsg = sprintf('Bad parameter value "%s", resetting to "%s"', ...
                   num2str(cv), preventry);
    uiwait(warndlg(wmsg, 'DISTTOOL', 'modal'))
    set(ud.pslider(sliderno),'Value',pv);
    set(ud.pfhndl(sliderno),'String',preventry);
end

% turn this callback back on after warning dialog dismissed
set(ud.pslider(sliderno),'Callback',cbstr);


%-----------------------------------------------------------------------------
% Callback for controlling the parameter values using editable text boxes.
function ud = setpfield(fieldno,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
intparam = ud.dists(popupvalue).intparam(fieldno);
fieldentry = get(ud.pfhndl(fieldno),'String');
cv = str2double(fieldentry);
pmin = ud.dists(popupvalue).pmin(fieldno);
pmax = ud.dists(popupvalue).pmax(fieldno);
phivalue = str2double(get(ud.hihndl(fieldno),'String'));
plovalue = str2double(get(ud.lohndl(fieldno),'String'));
if intparam 
    cv = round(cv);
    set(ud.pfhndl(fieldno),'String',num2str(cv));
end
if okwithminmax(cv, pmin, pmax, popupvalue, fieldno, ud) && ... 
                 slidervaluesok(popupvalue, cv, fieldno, ud)
    set(ud.pslider(fieldno),'Value',cv);
    if (cv > phivalue), 
        set(ud.hihndl(fieldno),'String',num2str(cv));
        set(ud.pslider(fieldno),'Max',cv);
        ud.dists(popupvalue).phi(fieldno) = cv;
    end
    if (cv < plovalue), 
        set(ud.lohndl(fieldno),'String',num2str(cv));
        set(ud.pslider(fieldno),'Min',cv);
        ud.dists(popupvalue).plo(fieldno) = cv;
    end
    ud.dists(popupvalue).parameters(fieldno) = cv;
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
	yvalues = getnewy(xvalues,ud);
    newy = getnewy(newx,ud);
    setsliderstep(ud.pslider(fieldno),intparam);
    ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy); 
else
    preventry = num2str(ud.dists(popupvalue).parameters(fieldno));
    set(ud.pfhndl(fieldno),'String',preventry);
    wmsg = sprintf('Bad parameter value "%s", resetting to "%s"', ...
                   fieldentry, preventry);
    uiwait(warndlg(wmsg, 'DISTTOOL', 'modal'))
    set(ud.pfhndl(fieldno),'String',num2str(preventry));
end

% END CALLBACK FUNCTIONS.
