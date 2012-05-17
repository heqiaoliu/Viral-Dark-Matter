function fout = waitbar(x,whichbar, varargin)
%WAITBAR Display wait bar.
%   H = WAITBAR(X,'message', property, value, property, value, ...)
%   creates and displays a waitbar of fractional length X.  The
%   handle to the waitbar figure is returned in H.
%   X should be between 0 and 1.  Optional arguments property and
%   value allow to set corresponding waitbar figure properties.
%   Property can also be an action keyword 'CreateCancelBtn', in
%   which case a cancel button will be added to the figure, and
%   the passed value string will be executed upon clicking on the
%   cancel button or the close figure button.
%
%   WAITBAR(X) will set the length of the bar in the most recently
%   created waitbar window to the fractional length X.
%
%   WAITBAR(X,H) will set the length of the bar in waitbar H
%   to the fractional length X.
%
%   WAITBAR(X,H,'message') will update the message text in
%   the waitbar figure, in addition to setting the fractional
%   length to X.
%
%   WAITBAR is typically used inside a FOR loop that performs a
%   lengthy computation.
%
%   Example:
%       h = waitbar(0,'Please wait...');
%       for i=1:1000,
%           % computation here %
%           waitbar(i/1000,h)
%       end
%
%   See also DIALOG, MSGBOX.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.23.4.21 $  $Date: 2009/12/11 20:36:51 $

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('waitbar');

inWaitbarCreate = true;

if (nargin == 0)
    error('MATLAB:waitbar:InvalidArguments', 'Input arguments not valid.');
elseif (nargin > 0)
    % Must be a numeric value
    if ~isnumeric(x) || ~isscalar(x)
        error('MATLAB:waitbar:InvalidInputs', 'The first argument must be a numeric value between 0 and 1.');
    elseif ((x < 0) || (x > 1))
        % Throw a warning in this case, clamp it down and keep going
        % this is a behavior change and we want to eventually error out in this scenario, 
        % but want to do that gradually
        if (x < 0)
            x = 0;
        elseif (x > 1)
            x = 1;
        end
        % This warning will be enabled when callers no longer send in values 
        % outside the allowed range
        % warning('MATLAB:waitbar:invalidValue', '%s\n%s%s', ...
        %    'The first argument must be a numeric value between 0 and 1.',...
        %    'Setting the value to: ', num2str(x));
    end
    
    if (nargin == 1)
        % A waitbar handle is not provided. Look for one.
        f = findobj(allchild(0),'flat','Tag','TMWWaitbar');
        
        if isempty(f)
            % No waitbar found. Create a new waitbar with a default string
            name = 'Waitbar';
        else
            % Found waitbar(s). Update the first (current) waitbar with the new value
            inWaitbarCreate = false;
            f = f(1);
        end
    elseif (nargin > 1)
        % A waitbar message or handle to an existing waitbar has been
        % provided
        if ischar(whichbar) || iscellstr(whichbar)
            % The second arg is a message, we are creating a waitbar
            name = whichbar;
        elseif all(ishghandle(whichbar, 'figure')) 
            % The second arg is a handle, we are updating the value
            inWaitbarCreate = false;
            f = whichbar;
        else
            error('MATLAB:waitbar:InvalidInputs', 'The second argument must be a message string or a handle to an existing waitbar.');
        end
    end
end

x = max(0,min(100*x,100)); % Map any value of x to a value between 0 and 100
try
    if inWaitbarCreate
        % waitbar(x,name)  initialize
        createWaitbar(varargin{:});
    else
        % waitbar(x)    update
        updateWaitbar(varargin{:});
    end  % inWaitbarCreate
catch ex
    err = MException('MATLAB:waitbar:InvalidArguments','Improper arguments for waitbar.');
    err = err.addCause(ex);
    close(findobj(allchild(0),'flat','Tag','TMWWaitbar'));
    throw(err);
end
drawnow;

if nargout==1,
    fout = f;
end

    function createWaitbar(varargin)
        vertMargin = 0;
        if nargin > 0,
            % we have optional arguments: property-value pairs
            if rem (nargin, 2 ) ~= 0
                error('MATLAB:waitbar:InvalidOptionalArgsPass',  'Optional initialization arguments must be passed in pairs.');
            end
        end
        
        
        oldRootUnits = get(0,'Units');
        % Restore the Units safely
        c = onCleanup(@()set(0, 'Units', oldRootUnits));

        set(0, 'Units', 'points');
        screenSize = get(0,'ScreenSize');
        delete(c);
        
        axFontSize=get(0,'FactoryAxesFontSize');
        
        pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
        
        width = 360 * pointsPerPixel;
        height = 75 * pointsPerPixel;
        pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
        
        f = figure(...
            'Units', 'points', ...
            'BusyAction', 'queue', ...
            'WindowStyle', 'normal', ...
            'Position', pos, ...
            'Resize','off', ...
            'CreateFcn','', ...
            'NumberTitle','off', ...
            'IntegerHandle','off', ...
            'MenuBar', 'none', ...
            'Tag','TMWWaitbar',...
            'Interruptible', 'off', ...
            'DockControls', 'off', ...
            'Visible','off');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set figure properties as passed to the fcn
        % pay special attention to the 'cancel' request
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        visValue = 'on';
        if nargin > 0,
            propList = varargin(1:2:end);
            valueList = varargin(2:2:end);
            cancelBtnCreated = 0;
            
            visibleExist = strmatch('vis',lower(propList));
            if ~isempty(visibleExist)
                visValue = valueList{visibleExist};
            end
            
            for ii = 1:length( propList )
                try
                    if strcmpi(propList{ii}, 'createcancelbtn' ) && ~cancelBtnCreated
                        cancelBtnHeight = 23 * pointsPerPixel;
                        cancelBtnWidth = 60 * pointsPerPixel;
                        newPos = pos;
                        vertMargin = vertMargin + cancelBtnHeight;
                        newPos(4) = newPos(4)+vertMargin;
                        callbackFcn = [valueList{ii}];
                        set( f, 'Position', newPos, 'CloseRequestFcn', callbackFcn );
                        cancelButt = uicontrol('Parent',f, ...
                            'Units','points', ...
                            'Callback',callbackFcn, ...
                            'ButtonDownFcn', callbackFcn, ...
                            'Enable','on', ...
                            'Interruptible','off', ...
                            'Position', [pos(3)-cancelBtnWidth*1.4, 7,  ...
                            cancelBtnWidth, cancelBtnHeight], ...
                            'String','Cancel', ...
                            'Tag','TMWWaitbarCancelButton'); %#ok<NASGU>
                        cancelBtnCreated = 1;
                    else
                        % simply set the prop/value pair of the figure
                        set( f, propList{ii}, valueList{ii});
                    end
                catch ex
                    fprintf('Warning: Could not set property value\nProperty: %s\nValue:%s\n', ...
                        propList{ii}, num2str(valueList{ii}));
                end
            end
        end
        
        colormap([]);
        
        axNorm=[.05 .3 .9 .2];
        axPos=axNorm.*[pos(3:4),pos(3:4)] + [0 vertMargin 0 0];
        
        h = axes('Parent', f, ...
            'XLim',[0 100],...
            'YLim',[0 1],...
            'Box','on', ...
            'Units','Points',...
            'FontSize', axFontSize,...
            'Position',axPos,...
            'XTickMode','manual',...
            'YTickMode','manual',...
            'XTick',[],...
            'YTick',[],...
            'XTickLabelMode','manual',...
            'XTickLabel',[],...
            'YTickLabelMode','manual',...
            'YTickLabel',[],...
            'Visible', 'off');
        
        tHandle=get(h,'title');
        oldTitleUnits=get(tHandle,'Units');
        set(tHandle,...
            'Units',      'points',...
            'String',     name,...
            'Visible',    'on');
        
        tExtent=get(tHandle,'Extent');
        set(tHandle,'Units',oldTitleUnits);
        
        titleHeight=tExtent(4)+axPos(2)+axPos(4)+5;
        if titleHeight>pos(4)
            pos(4)=titleHeight;
            pos(2)=screenSize(4)/2-pos(4)/2;
            figPosDirty=true;
        else
            figPosDirty=false;
        end
        
        if tExtent(3)>pos(3)*1.10;
            pos(3)=min(tExtent(3)*1.10,screenSize(3));
            pos(1)=screenSize(3)/2-pos(3)/2;
            
            axPos([1,3])=axNorm([1,3])*pos(3);
            set(h,'Position',axPos);
            
            figPosDirty=true;
        end
        
        if figPosDirty
            set(f,'Position',pos);
        end
        
        uiwaitbar(f, 'create', x, axPos);
        
        set(f,'HandleVisibility','callback','visible', visValue);
    end

    function updateWaitbar(varargin)
        uiwaitbar(f, 'update', x);
        
        if nargin>0
            % Update waitbar title:
            hAxes = findobj(f,'type','axes');
            hTitle = get(hAxes,'title');
            set(hTitle,'string',varargin{1});
        end
    end
end
