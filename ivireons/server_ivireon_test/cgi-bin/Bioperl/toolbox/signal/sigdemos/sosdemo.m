function sosdemo
%SOSDEMO Second Order Sections Demonstration for the Signal Processing Toolbox.
%
% This demo lets you examine the internal structure of a digital filter.
%
% It designs a Butterworth, Chebyshev type I or II, or elliptic digital
% filter of the specified "order" and with the specified cutoff frequencies.
%
% "Order" specifies the filter order for lowpass filters, and half the filter
% order for bandpass filters.
%
% "Filter cutoffs" can be a two element vector for bandpass filters, or a
% scalar for lowpass filters.
%
% The function ZP2SOS transforms a digital filter into "second order sections" form.
%
% It groups pairs of poles and zeros together so that the cascade of the
% second order filters (or "sections") is equivalent to the original filter.
%
% ZP2SOS pairs the pole-zero pairs, orders them, and scales them, so that in
% certain fixed point implementations the cascade filter avoids overflow and
% has minimal noise gain.
%
% The "Up" and "Down" options tell ZP2SOS which way to order the sections:
%     "Up"   - places pole-zero pairs with poles closest to the unit circle
%              (high "Q" filters) at end of cascade.
%     "Down" - places pole-zero pairs in the opposite order.
% The slider at the bottom of the figure lets you choose one of the responses
% to highlight or display. You can also highlight a response by clicking on it.
%
% The four toggle switches on the right have the following effects:
% "Show all" - shows all of the sections at once or just the selected one.
% "3-D plot" - allows you change from a 3-D to a 2-D view.
% "Cascade"  - with this turned on, the n-th response is the cascade of
%              sections 1 through n. If turned off, the n-th response is
%              simply the response of section n.
% "Grid"     - toggles grid on and off.
%
% See also CZTDEMO, FILTDEMO, MODDEMO.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2007/12/14 15:03:33 $

if isunix
    pf = 1;
else
    pf = get(0, 'screenPixelsPerInch')/96;
end

h.figure = figure( ...
    'Menubar', 'None', ...
    'Visible', 'Off', ...
    'Name','Second Order Sections Demo', ...
    'handlevisibility','off',...
    'IntegerHandle','off',...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'NumberTitle','off');

h.layout = siglayout.gridbaglayout(h.figure, ...
    'HorizontalWeights', [1 0 0], ...
    'VerticalWeights', [1 0 0 0]);

% Set up the axes
h.axesframe = uicontainer('Parent', h.figure);
h.axes      = axes('Parent', h.axesframe, ...
    'OuterPosition',[0 0 1 1]);
h.layout.add(h.axesframe, 1, [1 2], ...
    'Fill', 'Both', ...
    'TopInset', 4*pf);


% Set up the scroll bar
h.slider = uicontrol(h.figure, ...
    'Style','slider', ...
    'Value',6, ...
    'userdata',6, ...
    'min',1, ...
    'max',6, ...
    'SliderStep', [.2 .2], ...
    'Interruptible','off', ...
    'Callback',@slide_cb);
h.layout.add(h.slider, 2, [1 2], ...
    'Fill', 'Horizontal', ...
    'LeftInset', 10*pf, ...
    'MinimumHeight', 20*pf);
h.left = uicontrol(h.figure, ...
    'Style','text', ...
    'Horiz','left', ...
    'String','1');
h.right = uicontrol(h.figure, ...
    'Style','text', ...
    'Horiz','right', ...
    'String','6');
h.layout.add(h.left, 3, 1, ...
    'Anchor', 'West', ...
    'MinimumHeight', 20*pf, ...
    'LeftInset', 10*pf);
h.layout.add(h.right, 3, 2, ...
    'MinimumHeight', 20*pf, ...
    'Anchor', 'East');

% Set up the "Console"
h.consoleframe = uipanel(h.figure, ...
    'BorderType', 'beveledin', ...
    'BackgroundColor', [.5 .5 .5]);
h.layout.add(h.consoleframe, [1 3], 3, ...
    'Fill', 'Both', ...
    'MinimumWidth', 140*pf, ...
    'TopInset', 10*pf, ...
    'BottomInset', 10*pf, ...
    'LeftInset', 10*pf, ...
    'RightInset', 10*pf);
h.consolelayout = siglayout.gridbaglayout(h.consoleframe, ...
    'VerticalGap', 10*pf, ...
    'HorizontalGap', 10*pf, ...
    'VerticalWeights', [0 0 0 0 0 0 0 0 0 0 1], ...
    'HorizontalWeights', [0 1]);

% The UPDOWN Menu
h.updown = uicontrol(h.figure, ...
    'Style','popupmenu', ...
    'BackgroundColor', 'w', ...
    'String',{'Up', 'Down'}, ...
    'Interruptible','on', ...
    'Callback',@lcl_filter);
h.consolelayout.add(h.updown, 1, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% The FILTER Menu
h.filter = uicontrol(h.figure, ...
    'Style','popupmenu', ...
    'BackgroundColor', 'w', ...
    'String',{'Butter', 'Cheby1', 'Cheby2', 'Ellip'}, ...
    'Interruptible','on', ...
    'Value',3,...   % chebyshev type 2
    'Callback',@lcl_filter);
h.consolelayout.add(h.filter, 2, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% Filter order
h.order_lbl = uicontrol(h.figure, ...
    'Style','text', ...
    'Horiz','left', ...
    'String','Order:', ...
    'Interruptible','off', ...
    'BackgroundColor',[0.5 0.5 0.5], ...
    'ForegroundColor','white');
h.order = uicontrol(h.figure, ...
    'Style','edit', ...
    'Horiz','right', ...
    'Background','white', ...
    'Foreground','black', ...
    'String','6','Userdata',6, ...
    'callback',@order_cb);
h.consolelayout.add(h.order_lbl, 3, 1, ...
    'MinimumHeight', 17*pf, ...
    'MinimumWidth', largestuiwidth(h.order_lbl)+2, ...
    'Fill', 'Horizontal', ...
    'Anchor', 'South');
h.consolelayout.add(h.order, 3, 2, ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% Filter cutoff
h.cutoff_lbl = uicontrol(h.figure, ...
    'Style','text', ...
    'Horiz','left', ...
    'String','Cutoffs:', ...
    'Interruptible','off', ...
    'BackgroundColor',[0.5 0.5 0.5], ...
    'ForegroundColor','white');
h.cutoff = uicontrol(h.figure, ...
    'Style','edit', ...
    'Horiz','right', ...
    'Background','white', ...
    'Foreground','black', ...
    'String','[0.4 0.7]','Userdata',[.4 .7], ...
    'callback',@cutoff_cb);
h.consolelayout.add(h.cutoff_lbl, 4, [1 2], ...
    'BottomInset', -15*pf, ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');
h.consolelayout.add(h.cutoff, 5, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% Show all
h.showall = uicontrol(h.figure, ...
    'Style','checkbox', ...
    'String','Show all', ...
    'Value',1, ...
    'Callback',@show_cb);
h.consolelayout.add(h.showall, 6, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% 3-D Plot
h.threedplot = uicontrol(h.figure, ...
    'Style','checkbox', ...
    'String','3-D plot', ...
    'Value',1, ...
    'Callback',@three_d_plot_cb);
h.consolelayout.add(h.threedplot, 7, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% Cascade
h.cascade = uicontrol(h.figure, ...
    'Style','checkbox', ...
    'String','Cascade', ...
    'Value',1, ...
    'Callback',@createplot);
h.consolelayout.add(h.cascade, 8, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% Grid
h.grid = uicontrol(h.figure, ...
    'Style','checkbox', ...
    'String','Grid', ...
    'Value',1, ...
    'Callback',@grid_cb);
h.consolelayout.add(h.grid, 9, [1 2], ...
    'MinimumHeight', 20*pf, ...
    'Fill', 'Horizontal');

% The INFO button
h.help=uicontrol(h.figure, ...
    'Style','pushbutton', ...
    'String','Info', ...
    'Callback',@info_cb);
h.consolelayout.add(h.help, 10, [1 2], ...
    'MinimumHeight', 25*pf, ...
    'Fill', 'Horizontal');

% The CLOSE button
h.close = uicontrol(h.figure, ...
    'Style','pushbutton', ...
    'String','Close', ...
    'Callback','close(gcbf)');
h.consolelayout.add(h.close, 11, [1 2], ...
    'MinimumHeight', 25*pf, ...
    'Anchor', 'North', ...
    'Fill', 'Horizontal');

h.line = [];

lcl_filter;

set(h.figure, 'Visible','on');

% ------------------------------------------------------
    function lineclick_cb(hcbo, eventStruct, s);

        if get(h.showall,'value')==1, % Show all
            set(h.line,'color',linecolor(1))
            set(h.line(s),'color',linecolor(2))
        else
            set(h.line,'visible','off','color',linecolor(1))
            set(h.line(s),'visible','on','color',linecolor(2))
        end
        set(h.slider,'value',s,'userdata',s);
        puttitle;
    end
% ------------------------------------------------------
    function puttitle(hcbo, eventStruct)

        v = get(h.slider,'value');  % section selection
        cascade = get(h.cascade,'value');
        if cascade
            title(h.axes, sprintf( ...
                'Cumulative Cascade Responses (through section %g highlighted)', v))
        else
            title(h.axes, sprintf( ...
                'Response of Individual Sections (section %g highlighted)', v))
        end
    end
% ------------------------------------------------
    function lcl_filter(hcbo, eventStruct)

        % store the second order sections in the UserData of the filter popup
        set(h.figure,'Pointer','watch');

        v = get(h.filter,'value');
        op = get(h.filter,'string'); op = deblank(op(v,:));
        n = get(h.order,'UserData');
        set(h.slider,'value',n);
        wn = get(h.cutoff,'UserData');
        v = get(h.updown,'value');
        updown = get(h.updown,'String'); updown = deblank(updown(v,:));
        cascade = get(h.cascade,'value');
        gr = get(h.grid,'value');

        Rpass = 3; Rstop = 30;
        if strcmp(op,'Butter'),
            [z,p,k] = butter(n,wn);
        elseif strcmp(op,'Cheby1'),
            [z,p,k] = cheby1(n,Rpass,wn);
        elseif strcmp(op,'Cheby2'),
            [z,p,k] = cheby2(n,Rstop,wn);
        elseif strcmp(op,'Ellip'),
            [z,p,k] = ellip(n,Rpass,Rstop,wn);
        else
            error(generatemsgid('InvalidParam'),'Unknown filter type.');
        end
        sos = zp2sos(z,p,k,lower(updown));

        section = size(sos,1);
        set(h.slider,'max',section);
        val = min(section,get(h.slider,'value'));
        set(h.slider,'value',val,'userdata',val);
        set(h.filter,'UserData',sos)
        set(h.figure,'Pointer','arrow');
        createplot;
    end
% ------------------------------------------------
    function createplot(hcbo, eventStruct)
        
        set(h.figure,'Pointer','watch');

        v = get(h.filter,'value');
        op = get(h.filter,'string'); op = deblank(op(v,:));
        n = get(h.order,'UserData');
        wn = get(h.cutoff,'UserData');
        
        % Sometimes the slider doesn't "stick" properly.  Don't know why,
        % looks like an HG problem.
        section = round(get(h.slider,'value'));
        v = get(h.updown,'value');
        updown = get(h.updown,'String'); updown = deblank(updown(v,:));
        cascade = get(h.cascade,'value');

        sos = get(h.filter,'UserData');

        % Now plot response
        np = 256; m = size(sos,1);
        delete(h.line);
        h.line = []; H = zeros(np,m);
        [H(:,1),F] = freqz(sos(1,1:3),sos(1,4:6),np,2);
        for i=2:m,
            if cascade,
                H(:,i) = H(:,i-1).*freqz(sos(i,1:3),sos(i,4:6),np,2);
            else
                H(:,i) = freqz(sos(i,1:3),sos(i,4:6),np,2);
            end
        end
        warnsave = warning;  % turn off "Log of zero" messages
        warning('off')
        H = 20*log10(abs(H));
        warning(warnsave)
        max_pt = max(max(H));
        for i=1:m,
            h.line=[h.line,line((i)*ones(np,1),F,H(:,i), ...
                'buttondownfcn',{@lineclick_cb, i}, 'parent', h.axes)];
        end
        set(h.line(section),'color',linecolor(2));
        if get(h.showall,'value')==0,
            invis = 1:m; invis(section) = []; set(h.line(invis),'visible','off');
        end
        if get(h.threedplot,'value')==1,
            view(h.axes, 60, 30)
        else
            view(h.axes, 90, 0)
        end
        set(h.axes, 'zlimmode', 'auto');

        grid_cb;
                
        set(h.right,'String',int2str(m),'UserData',m)
        set(h.slider,'Max',m,'Value',section)

        puttitle;

        xlabel(h.axes, 'Section');
        ylabel(h.axes, 'Frequency');
        zlabel(h.axes, 'Magnitude (dB)');
        set(h.figure,  'Pointer', 'arrow');
    end
% ------------------------------------------------
    function order_cb(hcbo, eventStruct)

        v = get(h.order,'UserData');
        s = get(h.order,'String');
        vv = eval(s,num2str(v));
        if vv<1, vv = v; end
        vv = round(vv);
        set(h.order,'Userdata',vv,'String',num2str(vv))
        set(h.slider, 'SliderStep', [1 1]./(vv-1));
        lcl_filter;
    end
% ------------------------------------------------
    function cutoff_cb(hcbo, eventStruct)

        v = get(h.cutoff,'UserData');
        s = get(h.cutoff,'String');
        if length(v) == 1,
            vv = eval(s,num2str(v));
        else
            vv = eval(s,['[' num2str(v(1)) ' ' num2str(v(2)) ']']);
        end
        if any(vv<0 | vv>1), vv = v; end
        if length(vv)>1, if diff(vv)<0, vv = v; end, end
        vv = round(vv*100)/100;
        if length(vv) == 2
            set(h.cutoff,'Userdata',vv, ...
                'String', [ '[' num2str(vv(1)) ' ' num2str(vv(2)) ']' ] )
        else
            set(h.cutoff,'Userdata',vv,'String', [ '[' num2str(vv(1)) ']' ] )
        end
        if ~all(v == vv), lcl_filter, end
    end
% ------------------------------------------------
    function show_cb(hcbo, eventStruct)

        v = get(h.showall,'value');
        hlast = floor(get(h.slider,'value')); % Slider value
        if v==1,
            set(h.line,'visible','on')
        else
            set(h.line,'visible','off')
            set(h.line(hlast),'visible','on')
        end
    end
% ------------------------------------------------
    function three_d_plot_cb(hcbo, eventStruct)

        v = get(h.threedplot,'value');
        if v==1
            view(h.axes, 60,30)
        else
            view(h.axes, 90,0)
        end
    end
% ------------------------------------------------
    function grid_cb(hcbo, eventStruct)

        if get(h.grid,'value')
            grid(h.axes, 'on');
        else
            grid(h.axes, 'off');
        end
    end
% ------------------------------------------------
    function info_cb(hcbo, eventStruct)

        set(h.figure,'pointer','arrow')
        ttlStr = get(h.figure,'Name');
        hlpStr = [ ...
            'This demo lets you examine the internal structure of a digital filter.     '
            '                                                                           '
            'It designs a Butterworth, Chebyshev type I or II, or elliptic digital fil- '
            'ter of the specified "order" and with the specified cutoff frequencies.    '
            '                                                                           '
            '"Order" specifies the filter order for lowpass filters, and half the filter'
            'order for bandpass filters.                                                '
            '                                                                           '
            '"Filter cutoffs" can be a two element vector for bandpass filters, or a    '
            'scalar for lowpass filters.                                                '
            '                                                                           '
            'The function ZP2SOS transforms a digital filter into "second order         '
            'sections" form.                                                            '
            '                                                                           '
            'It groups pairs of poles and zeros together so that the cascade of the     '
            'second order filters (or "sections") is equivalent to the original filter. '
            '                                                                           '
            'ZP2SOS pairs the pole-zero pairs, orders them, and scales them, so that in '
            'certain fixed point implementations the cascade filter avoids overflow and '
            'has minimal noise gain.                                                    '
            '                                                                           '
            'The "Up" and "Down" options tell ZP2SOS which way to order the sections:   '
            '    "Up"   - places pole-zero pairs with poles closest to the unit circle  '
            '             (high "Q" filters) at end of cascade.                         '
            '    "Down" - places pole-zero pairs in the opposite order.                 '
            'The slider at the bottom of the figure lets you choose one of the resp-    '
            'onses to highlight or display. You can also highlight a response by        '
            'clicking on it.                                                            '
            '                                                                           '
            'The four toggle switches on the right have the following effects:          '
            '"Show all" - shows all of the sections at once or just the selected one.   '
            '"3-D plot" - allows you change from a 3-D to a 2-D view.                   '
            '"Cascade"  - with this turned on, the n-th response is the cascade of sec- '
            '             tions 1 through n. If turned off, the n-th response is simply '
            '             the response of section n.                                    '
            '"Grid"     - toggles grid on and off.                                      '];

        helpwin(hlpStr,ttlStr);
        return  % avoid fancy, self-modifying code which
        % is killing the callback to this window's close button
        % if you press the info button more than once.
        % Also, a bug on Windows MATLAB is killing the
        % callback if you hit the info button even once!

        % Protect against gcf changing -- Change close button behind
        % helpwin's back
        ch = get(h.figure,'ch');
        for i=1:length(ch),
            if strcmp(get(ch(i),'type'),'uicontrol'),
                if strcmp(lower(get(ch(i),'String')),'close'),
                    callbackStr = [get(ch(i),'callback') ...
                        '; sosdemo(''closehelp'',' num2str(h.figure) ')'];
                    set(ch(i),'callback',callbackStr)
                    return
                end
            end
        end
    end
% ------------------------------------------------
    function slide_cb(hcbo, eventStruct)

        v = get(h.slider,'value');
        v = round(v);
        set(h.slider,'value',v);
        if get(h.showall,'value')==1, % Show all
            set(h.line,'color',linecolor(1))
            set(h.line(v),'color',linecolor(2))
        else
            set(h.line,'visible','off','color',linecolor(1))
            set(h.line(v),'visible','on','color',linecolor(2))
        end
        puttitle
    end
% ------------------------------------------------
    function c = linecolor(num)
        % LINECOLOR Return the line color of a line
        %  Input = 1 or 2, 1 for highlighted, 2 for not highlighted

        co = get(h.figure,'defaultaxescolororder');
        c = co(min(num,size(co,1)),:);
    end
end

% [EOF]
