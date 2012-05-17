function hh = area(varargin)
    %AREA  Filled area plot.
    %   AREA(X,Y) produces a stacked area plot suitable for showing the
    %   contributions of various components to a whole.
    %
    %   For vector X and Y, AREA(X,Y) is the same as PLOT(X,Y) except that
    %   the area between 0 and Y is filled.  When Y is a matrix, AREA(X,Y)
    %   plots the columns of Y as filled areas.  For each X, the net
    %   result is the sum of corresponding values from the columns of Y.
    %
    %   AREA(Y) uses the default value of X=1:SIZE(Y,1).
    %
    %   AREA(X,Y,LEVEL) or AREA(Y,LEVEL) specifies the base level
    %   for the area plot to be at the value y=LEVEL.  The default
    %   value is LEVEL=0.
    %
    %   AREA(...,'Prop1',VALUE1,'Prop2',VALUE2,...) sets the specified
    %   properties of the underlying areaseries objects.
    %
    %   AREA(AX,...) plots into axes with handle AX. Use GCA to get the
    %   handle to the current axes or to create one if none exist.
    %
    %   H = AREA(...) returns a vector of handles to areaseries objects.
    %
    %   See also PLOT, BAR.
    
    %   Copyright 1984-2009 The MathWorks, Inc.
    %   $Revision: 1.20.4.19 $  $Date: 2009/06/22 14:40:05 $
    
    % First we check whether Handle Graphics uses MATLAB classes
    isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');
    
    % Next we check whether to use the V6 Plot API
    [v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);
    
    if isHGUsingMATLABClasses
        h = areaHGUsingMATLABClasses(args{:});
    elseif v6
        h = Lareav6(args{:});
    else
        % Parse possible Axes input
        [cax,args] = axescheck(args{:});
        [args,pvpairs,msg] = parseargs(args);
        if ~isempty(msg), error(msg); end
        nargs = length(args);
        
        [msg,x,y] = xychk(args{1:nargs},'plot');
        if ~isempty(msg), error(msg); end
        hasXData = nargs ~= 1;
        if min(size(x))==1, x = x(:); end
        if min(size(y))==1, y = y(:); end
        n = size(y,2);
        
        % handle vectorized data sources and display names
        extrapairs = cell(n,0);
        if ~isempty(pvpairs) && (n > 1)
            [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
                {'XDataSource','YDataSource','DisplayName'});
        end
        
        % Create plot
        if isempty(cax) || ishghandle(cax,'axes')
            cax = newplot(cax);
            parax = cax;
        else
            parax = cax;
            cax = ancestor(cax,'axes');
        end
        
        h = [];
        xdata = {};
        pkg = findpackage('specgraph');
        findclass(pkg,'areaseries');
        listeners = getappdata(0,'SpecgraphAreaListeners');
        seriesListeners = getappdata(0,'Graph2dSeriesListeners');
        set(listeners(2),'enable','off');
        set(seriesListeners(end),'enable','off');
        err = [];
        try
            for k=1:n
                % extract data from vectorizing over columns
                if hasXData
                    xdata = {'XData', datachk(x(:,k))};
                end
                h = [h specgraph.areaseries('YData',datachk(y(:,k)), ...
                    xdata{:}, pvpairs{:},...
                    extrapairs{k,:}, 'Parent', parax)];
            end
            set(h,'AreaPeers',h);
            if n > 1
                set(h(2:end),'RefreshMode','auto');
            end
        catch err
        end
        set(listeners(2),'enable','on');
        set(seriesListeners(end),'enable','on');
        if ~isempty(err)
            rethrow(err);
        end
        set(h(1),'RefreshMode','auto');
        
        plotdoneevent(cax,h);
        h = double(h);
    end
    if nargout>0, hh = h; end
end

function h = Lareav6(varargin)
    [cax,args,nargs] = axescheck(varargin{:});
    ax = newplot(cax);
    next = lower(get(ax,'NextPlot'));
    hold_state = ishold;
    
    % Search for the beginning of the prop,value pairs.
    for i=1:length(args),
        if ischar(args{i}), nargs = i-1; break, end
    end
    
    if nargs<3, level = 0; end
    
    % Make sure x and y are the same size
    if nargs<1,
        error(id('NotEnoughInputs'),'Not enough input arguments.');
    elseif nargs==1, % area(y)
        [msg,x,y] = xychk(args{1},'plot');
    elseif nargs==2 % area(x,y) or area(y,level)
        % area(y,level)
        if ~isequal(size(args{1}),size(args{2})) && ...
                length(args{2})==1,
            [msg,x,y] = xychk(args{1},'plot');
            level = args{2};
        else
            [msg,x,y] = xychk(args{1:2},'plot');
        end
    else % area(x,y,level)
        [msg,x,y] = xychk(args{1:2},'plot');
        level = args{3};
    end
    if ~isempty(msg), error(msg); end
    if all(size(level))~=1,
        error(id('LevelMustBeScalar'),'LEVEL must be a scalar.');
    end
    
    if min(size(y))==1, y = y(:); x = x(:); end
    [m,n] = size(y);
    
    if n>1,
        % Check for the same x spacing
        if all(all(abs(diff(x,2))<eps(class(x)))),
            y = cumsum(y,2); % Use fast calculation
        else
            xi = sort(x(:));
            yi = zeros(length(xi),size(y,2));
            for i=1:n,
                yi(:,i) = interp1(x(:,i),y(:,i),xi);
            end
            d = find(isnan(yi(:,1)));
            if ~isempty(d), yi(d,1) = level(ones(size(d))); end
            d = find(isnan(yi));
            if ~isempty(d), yi(d) = zeros(size(d)); end
            x = xi(:,ones(1,n));
            y = cumsum(yi,2);
            [m,n] = size(y);
        end
        xx = [x(1,:);x;flipud(x)];
        yy = [level(ones(m,1)) y];
        yy = [yy(1,1:end-1);yy(:,2:end);flipud(yy(:,1:end-1))];
    else
        xx = [x(1,:);x;flipud(x)];
        yy = [level;y;level(ones(m,1))];
    end
    
    h = []; cc = ones(size(xx,1),1);
    for i=1:size(y,2),
        h = [h,patch('XData',xx(:,i),'YData',yy(:,i),'CData',i*cc, ...
            'FaceColor','flat','EdgeColor',get(ax,'XColor'), ...
            args{nargs+1:end})];
    end
    
    if ~hold_state,
        view(2); set(ax,'NextPlot',next); set(ax,'Box','on')
        minx = min(x(:));
        maxx = max(x(:));
        if (minx == maxx)
            minx = maxx-1;
            maxx = maxx+1;
        end
        set(ax,'XLim',[minx maxx],'CLim',[1 max(n,2)])
    end
end

function [args,pvpairs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    % check for base value
    if length(args) > 1 && length(args{end}) == 1 && ...
            ~((length(args) == 2) && (length(args{1}) == 1) && (length(args{2}) == 1))
        pvpairs = {'BaseValue',args{end},pvpairs{:}};
        args(end) = [];
    end
    if isempty(args)
        msg.message = 'Must supply Y data or X and Y data as first argument(s).';
        msg.identifier = id('NoDataInputs');
    else
        msg = checkpvpairs(pvpairs,false);
    end
end

function str = id(str)
    str = ['MATLAB:area:' str];
end
