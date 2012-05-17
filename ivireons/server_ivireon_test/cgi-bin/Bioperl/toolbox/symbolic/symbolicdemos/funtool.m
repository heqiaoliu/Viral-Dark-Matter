function funtool(keyword,varargin)
%FUNTOOL A function calculator.
%   FUNTOOL is an interactive graphing calculator that manipulates
%   functions of a single variable.  At any time, there are two functions
%   displayed, f(x) and g(x).  The result of most operations replaces f(x).
%
%   The controls labeled 'f = ' and 'g = ' are editable text that may
%   be changed at any time to install a new function.  The control
%   labeled 'x = ' may be changed to specify a new domain.  The control
%   labeled 'a = ' may be changed to specify a new value of a parameter.
%
%   The top row of control buttons are unary function operators that
%   involve only f(x).  These operators are:
%      df/dx     - Symbolically differentiate f(x).
%      int f     - Symbolically integrate f(x).
%      simple f  - Simplify the symbolic expression, if possible.
%      num f     - Extract the numerator of a rational expression.
%      den f     - Extract the denominator of a rational expression.
%      1/f       - Replace f(x) by 1/f(x).
%      finv      - Replace f(x) by its inverse function.
%
%   The operators int(f) and finv may fail if the corresponding symbolic
%   expressions do not exist in closed form.
%
%   The second row of buttons translate and scale f(x) by the parameter 'a'.
%   The operations are:
%      f + a    - Replace f(x) by f(x) + a.
%      f - a    - Replace f(x) by f(x) - a.
%      f * a    - Replace f(x) by f(x) * a.
%      f / a    - Replace f(x) by f(x) / a.
%      f ^ a    - Replace f(x) by f(x) ^ a.
%      f(x+a)   - Replace f(x) by f(x + a).
%      f(x*a)   - Replace f(x) by f(x * a).
%
%   The third row of buttons are binary function operators that
%   operate on both f(x) and g(x).  The operations are:
%      f + g  - Replace f(x) by f(x) + g(x).
%      f - g  - Replace f(x) by f(x) - g(x).
%      f * g  - Replace f(x) by f(x) * g(x).
%      f / g  - Replace f(x) by f(x) / g(x).
%      f(g)   - Replace f(x) by f(g(x)).
%      g = f  - Replace g(x) by f(x).
%      swap   - Interchange f(x) and g(x).
%
%   The first three buttons in the fourth row manage a list of functions.
%   The Insert button places the current active function in the list.
%   The Cycle button rotates the function list.
%   The Delete button removes the active function from the list.  
%   The list of functions is named fxlist.  A default fxlist containing 
%           several interesting functions is provided.
%
%   The Reset button sets f, g, x, a and fxlist to their initial values.
%   The Help button prints this help text.  
%
%   The Demo button poses the following challenge: Can you generate the
%   function sin(x) without touching the keyboard, using just the mouse?
%   The demo does it with a reset and then nine clicks.  If you can do
%   it with fewer clicks, please send e-mail to moler@mathworks.com.
%
%   The Close button closes all three windows.
%
%   See also EZPLOT.

%   Copyright 1993-2009 The MathWorks, Inc. 
%       $Revision: 1.1.6.4 $  $Date: 2009/11/05 18:21:23 $

%Implementation Notes:
%   f,g, and a are syms.
%   x is a string. fxlist is a string matrix.
%
%   The values of f, g, a, and x are stored in the UserData of the text 
%     objects "f", "g", "a", and "x", respectively. These text objects are 
%     tagged "fobj", "gobj", "aobj", and "xstr", respectively.
%   fxlist is stored in the UserData of the control panel figure, which is 
%     tagged as "FUNTOOL_figp".
%   The edit text boxes for f, g, x, and a are tagged "Sf", "Sg", "Sx", and
%     "Sa", respectively.
%   The initial values of f, g, x, a, and fxlist are stored in a structure 
%     called init that has fields .f, .g, .x, .a and .l. The structure is 
%     stored in the UserData of the Reset button.

%%%%%%%%%%%%%%%%%%%%%%%%%%  Initialization section.
if nargin == 0
   
H = findobj(0,'Tag','FUNTOOL_figp');
if ~isempty(H)
   warning('symbolic:funtool:Started','Another FUNTOOL is running.  Only 1 FUNTOOL can be run at a time.');
   figure(H);
   Fhand = findobj(0,'Tag','figf');
   Ghand = findobj(0,'Tag','figg');
   figure(Fhand); figure(Ghand);
   return
end

init.f = 'x';
init.g = '1';
init.x = '[-2*pi, 2*pi]';
init.a = '1/2';
init.l = str2mat( ...
    historyfmt('1/(5+4*cos(x))','[-2*pi, 2*pi]'), ...
    historyfmt('cos(x^3)/(1+x^2)','[-2*pi, 2*pi]'), ...
    historyfmt('x^4*(1-x)^4/(1+x^2)','[0, 1]'), ...
    historyfmt('x^7-7*x^6+21*x^5-35*x^4+35*x^3-21*x^2+7*x-1','[0.985, 1.015]'), ...
    historyfmt('log(abs(sqrt(x)))','[0, 2]'), ...
    historyfmt('tan(sin(x))-sin(tan(x))','[-pi, pi]'));

f = sym(init.f); 
g = sym(init.g);
a = sym(init.a);
x = init.x;
fxlist = init.l;

% Macros
blanks = '  ';
p = .12*(1:7) - .02;
q = .60 - .14*(1:4);
r = [.10 .10];

% Position the two figures and the control panel.
figf = figure('Units','normalized','Position',[.01 .50 .45 .40],...
              'Menu','none','Tag','figf');
figg = figure('Units','normalized','Position',[.50 .50 .45 .40],...
              'Menu','none', 'Tag','figg');
FUNTOOL_figp = figure('Units','normalized','Position',[.25 .05 .48 .40],'Menu','none', ...
              'Tag','FUNTOOL_figp',...
              'Color',get(0,'DefaultUIControlBackgroundColor'), ...
              'DefaultUIControlUnit','norm','UserData',fxlist);

% Plot f(x) and g(x).
figure(figf)
ezplotWithCatch(f,x,figf)
figure(figg)
ezplotWithCatch(g,x,figg)

% Control panel
figure(FUNTOOL_figp);
axes('Parent',FUNTOOL_figp,'Visible','off');
uicontrol('Style','frame','Position',[0.01 0.60 0.98 0.38]);
uicontrol('Style','frame','Position',[0.01 0.01 0.98 0.58]);
uicontrol('Style','text','String','f = ','Position',[0.04 0.86 0.09 0.10],...
    'Tag','fobj','UserData',f);
uicontrol('Style','text','String','g = ','Position',[0.04 0.74 0.09 0.10],...
    'Tag','gobj','UserData',g);
uicontrol('Style','text','String','x = ','Position',[0.04 0.62 0.09 0.10],...
    'Tag','xstr','UserData',x);
uicontrol('Style','text','String','a = ','Position',[0.54 0.62 0.09 0.10],...
    'Tag','aobj','UserData',a);
uicontrol('Position',[.12 .86 .82 .10],'Style','edit','HorizontalAlignment','left', ...
    'BackgroundColor','white', ...
    'String', [blanks symchar(f)],'Tag','Sf', ...
    'CallBack','funtool Sfcallback');
uicontrol('Position',[.12 .74 .82 .10],'Style','edit','HorizontalAlignment','left', ...
    'BackgroundColor','white', ...
    'String', [blanks symchar(g)], 'Tag','Sg',...
    'CallBack','funtool Sgcallback');
uicontrol('Position',[.12 .62 .32 .10],'Style','edit','HorizontalAlignment','left', ...
    'BackgroundColor','white','String',[blanks x], 'Tag','Sx',...
    'CallBack','funtool Sxcallback');
uicontrol('Position',[.62 .62 .32 .10],'Style','edit','HorizontalAlignment','left', ...
    'BackgroundColor','white', 'Tag','Sa',...
    'String',[blanks symchar(a)],'CallBack','funtool Sacallback');

% Top row of unary operators. 
uicontrol('Position',[p(1) q(1) r],'String','df/dx', ...
   'CallBack','funtool(''row1'',''diff'')');
uicontrol('Position',[p(2) q(1) r],'String','int f', ...  
   'CallBack','funtool(''row1'',''int'')');
uicontrol('Position',[p(3) q(1) r],'String','simple f', ...  
   'CallBack','funtool(''row1'',''simple'')');
uicontrol('Position',[p(4) q(1) r],'String','num f', ...  
   'CallBack','funtool(''row1'',''num'')');
uicontrol('Position',[p(5) q(1) r],'String','den f', ...  
   'CallBack','funtool(''row1'',''den'')');
uicontrol('Position',[p(6) q(1) r],'String','1/f', ...  
   'CallBack','funtool(''row1'',''1/f'')');
uicontrol('Position',[p(7) q(1) r],'String','finv', ...  
   'CallBack','funtool(''row1'',''finverse'')');

% Second row of unary operators.  
uicontrol('Position',[p(1) q(2) r],'String','f+a', ...
   'CallBack','funtool(''row2'',''f+a'')');
uicontrol('Position',[p(2) q(2) r],'String','f-a', ...
   'CallBack','funtool(''row2'',''f-a'')');
uicontrol('Position',[p(3) q(2) r],'String','f*a', ...
   'CallBack','funtool(''row2'',''f*a'')');
uicontrol('Position',[p(4) q(2) r],'String','f/a', ...
   'CallBack','funtool(''row2'',''f/a'')');
uicontrol('Position',[p(5) q(2) r],'String','f^a', ...
   'CallBack','funtool(''row2'',''f^a'')');
uicontrol('Position',[p(6) q(2) r],'String','f(x+a)', ...
   'CallBack','funtool(''row2'',''f(x+a)'')');
uicontrol('Position',[p(7) q(2) r],'String','f(x*a)', ...
   'CallBack','funtool(''row2'',''f(x*a)'')');

% Third row, binary operators.
uicontrol('Position',[p(1) q(3) r],'String','f + g', ...
    'CallBack','funtool(''row3'',''f+g'')');
uicontrol('Position',[p(2) q(3) r],'String','f - g', ...
    'CallBack','funtool(''row3'',''f-g'')');
uicontrol('Position',[p(3) q(3) r],'String','f * g', ...
    'CallBack','funtool(''row3'',''f*g'')');
uicontrol('Position',[p(4) q(3) r],'String','f / g', ...
    'CallBack','funtool(''row3'',''f/g'')');
uicontrol('Position',[p(5) q(3) r],'String','f(g)', ...
    'CallBack','funtool(''row3'',''f(g)'')');
uicontrol('Position',[p(6) q(3) r],'String','g = f', ...
    'CallBack','funtool(''row3'',''g=f'')');
uicontrol('Position',[p(7) q(3) r],'String','swap', ...
    'CallBack','funtool(''row3'',''swap'')');

% Fourth row, auxiliary controls.
uicontrol('Position',[p(1) q(4) r],'String','Insert','CallBack','funtool Insert');
uicontrol('Position',[p(2) q(4) r],'String','Cycle','CallBack','funtool Cycle'); 
uicontrol('Position',[p(3) q(4) r],'String','Delete','CallBack','funtool Delete');
uicontrol('Position',[p(4) q(4) r],'String','Reset','Tag','reset', ...
    'UserData', init, 'CallBack', 'funtool Reset');
uicontrol('Position',[p(5) q(4) r],'String','Help', ...
    'CallBack','helpwin funtool');
uicontrol('Position',[p(6) q(4) r],'String','Demo', ...
    'CallBack','funtool Demo');
uicontrol('Position',[p(7) q(4) r],'String','Close', ...
    'CallBack','funtool close');

%%%%%%%%%%%%%%%%%%%%%%%%%%  end of Initialization section

else
    FUNTOOL_figp = gcbf;
    if isempty(FUNTOOL_figp)
        FUNTOOL_figp = findobj(0,'Tag','FUNTOOL_figp');
    end
switch keyword

%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback for top row of unary operators.
case 'row1'
   fhndl = findobj(FUNTOOL_figp,'Tag','fobj');
   f = get(fhndl,'UserData');
   x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
   figf = findobj(0,'Tag','figf');
   if ~isa(f,'sym')
       f = sym(f);   % f may be double; these functions require a sym
   end

   ok = true;
   switch varargin{1}
     case 'diff'
       f = diff(f);
     case 'int'
       f = int(f);
       if isempty(f) || ~isempty(strfind(char(f),'RootOf'))
           warndlg('Unable to find closed form expression for integral.','FUNTOOL');
           ok = false;
       end
     case 'simple'
       f = simple(f);
     case 'num'
       [f,~] = numden(f);
     case 'den'
       [~,f] = numden(f);
     case '1/f'
       f = 1/f;
     case 'finverse'
       try
          f = finverse(f);
       catch me
           warndlg(sprintf('Error calculating inv(f):\n%s',me.message),'FUNTOOL');
           ok = false;
       end
       if isempty(f) || ~isempty(strfind(char(f),'RootOf'))
           warndlg('Unable to find closed form expression for inverse.','FUNTOOL');
           ok = false;
       end
   end

   if ok
       ezplotWithCatch(f,x,figf)
       set(fhndl,'UserData',f);
       blanks = '  ';
       set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks symchar(f)]);
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback for second row of unary operators.
case 'row2'
   fhndl = findobj(FUNTOOL_figp,'Tag','fobj');
   f = get(fhndl,'UserData');
   x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
   a = get(findobj(FUNTOOL_figp,'Tag','aobj'),'UserData');
   figf = findobj(0,'Tag','figf');

   switch varargin{1}
     case 'f+a'
       f = f+a;
     case 'f-a'
       f = f-a;
     case 'f*a'
       f = f*a;
     case 'f/a'
       f = f/a;
     case 'f^a'
       f = f^a;
     case 'f(x+a)'
       f = subs(f,sym('x'),sym('x')+a);
     case 'f(x*a)', ...
       f = subs(f,sym('x'),sym('x')*a);
   end

   set(fhndl,'UserData',f);
   ezplotWithCatch(f,x,figf)
   blanks = '  ';
   set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks symchar(f)]);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback for third row, binary operators.
case 'row3'
   blanks = '  ';

   % Get variables.
   fhndl = findobj(FUNTOOL_figp,'Tag','fobj');
   ghndl = findobj(FUNTOOL_figp,'Tag','gobj');
   f = get(fhndl,'UserData');
   g = get(ghndl,'UserData');
   x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
   figf = findobj(0,'Tag','figf');
   figg = findobj(0,'Tag','figg');

   if strcmp(varargin{1}, 'g=f')
     g = f;
     set(ghndl,'UserData',g);
     ezplotWithCatch(g,x,figg)
     set(findobj(FUNTOOL_figp,'Tag','Sg'),'String',[blanks symchar(g)]);

   elseif strcmp(varargin{1}, 'swap')
     h = f; f = g; g = h;
     set(fhndl,'UserData',f);
     ezplotWithCatch(f,x,figf)
     set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks symchar(f)]);
     set(ghndl,'UserData',g);
     ezplotWithCatch(g,x,figg)
     set(findobj(FUNTOOL_figp,'Tag','Sg'),'String',[blanks symchar(g)]);

   else
     switch varargin{1}
       case 'f+g'
         f = f+g;
       case 'f-g'
         f = f-g; 
       case 'f*g'
         f = f*g; 
       case 'f/g'
         f = f/g; 
       case 'f(g)'
         f = compose(f,g); 
     end

     set(fhndl,'UserData',f);
     ezplotWithCatch(f,x,figf)
     set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks symchar(f)]);
   end

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for F's edit text box.
case 'Sfcallback'
    try
        f = sym(get(gcbo,'String'));
        fhndl = findobj(FUNTOOL_figp,'Tag','fobj');
        set(fhndl,'UserData',f);
        x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
        figf = findobj(0,'Tag','figf');
        ezplotWithCatch(f,x,figf)
    catch ex
        handleInvalidSym(ex);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for G's edit text box.
case 'Sgcallback'
    try
        g = sym(get(gcbo,'String'));
        ghndl = findobj(FUNTOOL_figp,'Tag','gobj');
        set(ghndl,'UserData',g);
        x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
        figg = findobj(0,'Tag','figg');
        ezplotWithCatch(g,x,figg)
    catch ex
        handleInvalidSym(ex);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for A's edit text box.
case 'Sacallback'
    try
        a = sym(get(gcbo,'String'));
        set(findobj(FUNTOOL_figp,'Tag','aobj'),'UserData',a);
    catch ex
        handleInvalidSym(ex);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for X's edit text box.
case 'Sxcallback'
   x = get(gcbo,'String');

   % add brackets if needed
   if isempty(x=='['),
      x = ['[' x ']'];
      blanks = '  ';
      set(gcbo,'String',[blanks x]),
   end;
   set(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData',x);

   fhndl = findobj(FUNTOOL_figp,'Tag','fobj');
   ghndl = findobj(FUNTOOL_figp,'Tag','gobj');
   f = get(fhndl,'UserData');
   g = get(ghndl,'UserData');
   figf = findobj(0,'Tag','figf');
   figg = findobj(0,'Tag','figg');
   
   ezplotWithCatch(f,x,figf)
   ezplotWithCatch(g,x,figg)

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Insert button.
case 'Insert'
   f = get(findobj(FUNTOOL_figp,'Tag','fobj'),'UserData');
   x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
   fxlist = get(FUNTOOL_figp,'UserData');
   fxlist = str2mat(fxlist,historyfmt(f, x));
   set(gcbf,'UserData',fxlist);

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Cycle button.
case 'Cycle'

   % Get variables.
   figf = findobj(0,'Tag','figf');
   fxlist = get(FUNTOOL_figp,'UserData');

   fx = fxlist(1,:); 
   fx(fx==' ') = [];
   k = find(fx == ';'); 
   fstr = fx(1:k-1); f = sym(fstr); 
   set(findobj(FUNTOOL_figp,'Tag','fobj'),'UserData',f);
   x = fx(k+1:length(fx)); 
   set(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData',x);

   blanks = '  ';
   set(findobj(FUNTOOL_figp,'Tag','Sx'),'String',[blanks x]); 
   set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks fstr]); 
   ezplotWithCatch(f,x,figf);
   k = [2:size(fxlist,1),1]; 
   fxlist = fxlist(k,:);
   set(FUNTOOL_figp,'UserData',fxlist);

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Delete button.
case 'Delete'

   % Get variables.
   f = get(findobj(FUNTOOL_figp,'Tag','fobj'),'UserData');
   x = get(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData');
   fxlist = get(FUNTOOL_figp,'UserData');

   fx = historyfmt(f,x); 
   fx(fx==' ') = [];
   for k = 1:size(fxlist,1), 
      element = fxlist(k,:);
      element(element==' ') = [];
      if strcmp(fx,element)
        fxlist(k,:) = []; 
        break 
      end 
   end; 
   if isempty(fxlist), fxlist = '0-0;  [0,1]'; end

   set(FUNTOOL_figp,'UserData',fxlist);

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Reset button.
case 'Reset'
   blanks = '  ';

   % Get variables.
   figf = findobj(0,'Tag','figf');
   figg = findobj(0,'Tag','figg');
   init = get(findobj(FUNTOOL_figp,'Tag','reset'),'UserData');

   set(findobj(FUNTOOL_figp,'Tag','fobj'),'UserData',sym(init.f));
   set(findobj(FUNTOOL_figp,'Tag','Sf'),'String',[blanks init.f]);
   ezplotWithCatch(sym(init.f),init.x,figf);

   set(findobj(FUNTOOL_figp,'Tag','gobj'),'UserData',sym(init.g));
   set(findobj(FUNTOOL_figp,'Tag','Sg'),'String',[blanks init.g]);
   ezplotWithCatch(sym(init.g),init.x,figg);

   set(findobj(FUNTOOL_figp,'Tag','xstr'),'UserData',init.x);
   set(findobj(FUNTOOL_figp,'Tag','Sx'),'String',[blanks init.x]);

   set(findobj(FUNTOOL_figp,'Tag','aobj'),'UserData',sym(init.a));
   set(findobj(FUNTOOL_figp,'Tag','Sa'),'String',[blanks init.a]);

   set(FUNTOOL_figp,'UserData',init.l);

   % Reset all buttons to default bkgd color.
   set(findobj(FUNTOOL_figp,'Style','pushbutton'),'BackgroundColor','default');

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Close button.
case 'close'
   close(findobj(0,'Tag','figf')); 
   close(findobj(0,'Tag','figg')); 
   close(findobj(0,'Tag','FUNTOOL_figp')); 

%%%%%%%%%%%%%%%%%%%%%%%%%% Callback for Demo button.
case 'Demo'

   % "B" is the vector of button handles in the control panel.
   % "prog" is a "program" consisting of button codes.

   prog = {'Reset','f/a','int f','f + g','1/f', ...
           'int f','finv','int f','df/dx','num f'};
   B = findobj(FUNTOOL_figp,'Style','pushbutton'); 
   for k = 1: length(prog)
      currB = findobj(B,'String',prog{k});
      set(currB,'BackgroundColor','white');
      eval(get(currB,'Callback'));
      pause(1)
      set(currB,'BackgroundColor','default');
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % switch statement for callbacks

end     % end of if statement


% -----------------------------------------------
function s = historyfmt(f,x)
    s = [symchar(f) ';' x];

function t=symchar(s)
if ~isa(s,'sym')
    s = sym(s);
end
t = char(s);

function ezplotWithCatch(s,x,fig)
try
    ezplot(s,x,fig)
catch %#ok
    clf(fig);
    ax = axes('parent',fig);
    text(.5,.5,'Unable to plot expression.','HorizontalAlignment','center',...
        'Parent',ax);
end

function handleInvalidSym(ex)
if strncmp(ex.identifier,'symbolic:',9)
    errordlg('Invalid symbolic expression.','Invalid Expression');
else
    rethrow(ex);
end
