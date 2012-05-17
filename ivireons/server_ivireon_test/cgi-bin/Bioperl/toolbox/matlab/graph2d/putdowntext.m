function varargout = putdowntext(varargin)
%PUTDOWNTEXT  Plot Editor helper function
%
%   See also PLOTEDIT

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.50.6.14 $  $Date: 2008/08/14 01:37:37 $

if ischar(varargin{1})
    fig = gcbf;
    if ~any(ishghandle(fig)), return, end
    action = varargin{1};
    toolButton = getappdata(fig,'ScribeCurrentToolButton');

    if nargin>1
      if ~isempty(toolButton)  % aborting one operation and starting another
         if ishghandle(toolButton) ...
            && strcmp(get(toolButton,'Type'),'uitoggletool') ...
            && toolButton ~= gcbo ...  % not the same button
            && ancestor(toolButton,'Figure') == fig % Same Window
            set(toolButton,'State','off');
         end
      end
      toolButton = varargin{2};
   end
else
    fig = varargin{1}(1);
    if ~any(ishghandle(fig)), return, end
    action = varargin{2};
    toolButton = getappdata(fig,'ScribeCurrentToolButton');
end

if ~any(ishghandle(fig)), return, end
setappdata(fig,'ScribeCurrentToolButton',toolButton);

stateData = getappdata(fig,'ScribeAddAnnotationStateData');
if isempty(stateData)
    stateData = LInitStateData(fig);
    setappdata(fig,'ScribeAddAnnotationStateData', stateData);
end


switch action

    case 'select'
        switch get(toolButton,'State')
            case 'off'
                plotedit(fig,'off');
            case 'on'
                plotedit(fig,'on');
        end

    case 'start'
        varargout{1} = 1;

        LSetSelect(fig,'off');  % plotedit off first

        LMaskAll(fig,'off');    % this saves windowXXXFcn settings
        set(toolButton,'State','on');

        set(fig,'Pointer',stateData.oldPointer);
        if any(ishghandle(stateData.myline))
            delete(stateData.myline);
        end
        stateData = LInitStateData(fig);
        setappdata(fig,'ScribeAddAnnotationStateData', stateData);

    case 'axesstart'
        if putdowntext('start')
            set(fig,'Pointer','crosshair',...
                'WindowButtonDownFcn','putdowntext hitaxes');
        end
    case 'hitaxes'
        rect = rbbox(fig);  % returns a rectangle in figure units
        units = get(fig,'Units');
        if all(rect(3:4) > 0)
            %jpropeditutils('jundo','start',fig);

            newAx = axes('Parent',fig,...
                'Units',units,...
                'Position',rect);
            set(newAx,'Units','normalized');

            %jpropeditutils('jundo','stop',fig);
        % Single click should open an axes at the bottom just like clicking
        % on the Axes icons in the FigurePalette (c.f. g367287)
        else 
            newAx = addsubplot(gcf,'Bottom','axes','Box','on','XGrid','off','YGrid','off','ZGrid','off');
        end
        putdowntext reset;
        % end add with plotedit on always
        LSetSelect(fig,'on'); % do this last

    case 'reset'

        try
            if any(ishghandle(stateData.myline))
                delete(stateData.myline);
                stateData.myline = [];
            end

            if any(ishghandle(fig))
                if ~isempty(toolButton)
                    set(toolButton,'State','off');
                end

                stateData = LInitStateData(fig);
                setappdata(fig,'ScribeAddAnnotationStateData', stateData);

                LMaskAll(fig,'on');  % restore
            end
        catch err %#ok<NASGU>
            % state may have changed while we were finishing
            % up. e.g. window closed etc.
        end

    case 'zoomin'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmode');
        else
            zoom(fig,'off')
        end

    case 'zoomout'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'outmode');
        else
            zoom(fig,'off')
        end
        
    case 'zoomx'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmodex');
        else
            zoom(fig,'off');
        end

    case 'zoomy'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmodey');
        else
            zoom(fig,'off');
        end
        
    case 'pan'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            if strcmpi(get(toolButton,'State'),'on')
                pan(fig,'onkeepstyle')
            else
                pan(fig,'off');
            end
        end

    case 'rotate3d'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            rotate3d(fig,get(toolButton,'State'));
        else
            rotate3d;
        end

    case 'datatip'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            datacursormode(fig,get(toolButton,'State'));
        end
    case 'brush'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            if strcmpi(get(toolButton,'State'),'on')
                brush(fig,'on')
            else
                brush(fig,'off')
            end
        end
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LMaskAll(fig,  setting)

        WindowFcnList = {...
            'Pointer',...
            'WindowButtonDownFcn', ...
            'WindowButtonMotionFcn',...
            'WindowButtonUpFcn'};

        savedSettings = getappdata(fig,'ScribeWindowMaskSettings');

        switch setting
            case 'on'  % restore
                if ~isempty(savedSettings) && isstruct(savedSettings)
                    set(fig, WindowFcnList, savedSettings.WindowFcns);
                    savedSettings = [];
                end
            case 'off' % save
                promoteoverlay(fig);
                savedSettings.WindowFcns = get(fig, WindowFcnList);
                set(fig, WindowFcnList(2:4), {'' '' ''});
        end

        setappdata(fig,'ScribeWindowMaskSettings',savedSettings);

        function LSetSelect(fig,state)
            if any(ishghandle(fig))
                switch state
                    case 'off'
                        scribeclearmode(fig,'putdowntext',fig,'reset');
                    case 'on'
                        plotedit(fig,'on');
                end
            end

            function stateData = LInitStateData(fig)
                stateData = struct(...
                    'x',[], ...
                    'y', [], ...
                    'myline', [], ...
                    'isarrow', 0, ...
                    'oldPointer', get(fig,'Pointer'));


