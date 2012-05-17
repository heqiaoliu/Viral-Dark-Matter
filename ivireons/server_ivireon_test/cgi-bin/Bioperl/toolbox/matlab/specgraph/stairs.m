function [xo,yo] = stairs(varargin)
    %STAIRS Stairstep plot.
    %   STAIRS(Y) draws a stairstep graph of the elements of vector Y.
    %
    %   STAIRS(X,Y) draws a stairstep graph of the elements in vector Y at
    %   the locations specified in X.
    %
    %   STAIRS(...,STYLE) uses the plot linestyle specified by the
    %   string STYLE.
    %
    %   STAIRS(AX,...) plots into AX instead of GCA.
    %
    %   H = STAIRS(X,Y) returns a vector of stairseries handles.
    %
    %   [XX,YY] = STAIRS(X,Y) does not draw a graph, but returns vectors
    %   X and Y such that PLOT(XX,YY) is the stairstep graph.
    %
    %   The above inputs to STAIRS can be followed by property/value
    %   pairs to specify additional properties of the stairseries object.
    %
    %   Stairstep plots are useful for drawing time history plots of
    %   zero-order-hold digital sampled-data systems.
    %
    %   See also BAR, HIST, STEM.
    
    %   L. Shure, 12-22-88.
    %   Revised A.Grace and C.Thompson 8-22-90.
    %   Copyright 1984-2009 The MathWorks, Inc.
    %   $Revision: 5.12.4.16 $  $Date: 2009/06/22 14:40:15 $
    
    % First we check whether Handle Graphics uses MATLAB classes
    isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');
    
    % Next we check whether to use the V6 Plot API
    [v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);
    
    if isHGUsingMATLABClasses
        if (nargout == 2)
            [xo,yo] = stairsHGUsingMATLABClasses(args{:});
        else
            h = stairsHGUsingMATLABClasses(args{:});
        end
    else
        if v6 || (nargout == 2)
            if (nargout == 2)
                [xo,yo] = Lstairsv6(args{:});
            else
                h = Lstairsv6(args{:});
            end
        else
            [cax,args,nargs] = axescheck(args{:});
            error(nargchk(1,inf,nargs,'struct'));
            [pvpairs,args,nargs,msg] = parseargs(args);
            if ~isempty(msg), error(msg); end
            error(nargchk(1,2,nargs,'struct'));
            
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
            
            if isempty(cax) || ishghandle(cax,'axes')
                cax = newplot(cax);
                parax = cax;
                next = lower(get(cax,'NextPlot'));
                hold_state = ishold(cax);
            else
                parax = cax;
                cax = ancestor(cax,'axes');
                hold_state = true;
                next = 'add';
            end
            
            h = [];
            autoColor = ~any(strcmpi('Color',pvpairs(1:2:end)));
            autoStyle = ~any(strcmpi('LineStyle',pvpairs(1:2:end)));
            xdata = {};
            for k=1:n
                % extract data from vectorizing over columns
                if hasXData
                    xdata = {'XData', datachk(x(:,k))};
                end
                [l,c,m] = nextstyle(cax,autoColor,autoStyle,k==1);
                h = [h specgraph.stairseries('YData',datachk(y(:,k)),xdata{:},...
                    'Color',c,'LineStyle',l,'Marker',m,...
                    pvpairs{:},extrapairs{k,:},'Parent',parax)];
            end
            if autoColor
                set(h,'CodeGenColorMode','auto');
            end
            set(h,'RefreshMode','auto');
            if ~hold_state, set(cax,'NextPlot',next); set(cax,'Box','on'); end
            plotdoneevent(cax,h);
            h = double(h);
        end
    end
    
    if nargout==1, xo = h(:); end
end

function [xo,yo] = Lstairsv6(varargin)
    [cax,args,nargs] = axescheck(varargin{:});
    error(nargchk(1,3,nargs,'struct'));
    
    sym = [];
    
    % Parse the inputs
    if ischar(args{nargs}), % stairs(y,'style') or stairs(x,y,'style')
        sym = args{nargs};
        [msg,x,y] = xychk(args{1:nargs-1},'plot');
        if ~isempty(msg), error(msg); end
    else % stairs(y), or stairs(x,y)
        [msg,x,y] = xychk(args{1:nargs},'plot');
        if ~isempty(msg), error(msg); end
    end
    
    if min(size(x))==1, x = x(:); end
    if min(size(y))==1, y = y(:); end
    
    [n,nc] = size(y);
    ndx = [1:n;1:n];
    y2 = y(ndx(1:2*n-1),:);
    if size(x,2)==1,
        x2 = x(ndx(2:2*n),ones(1,nc));
    else
        x2 = x(ndx(2:2*n),:);
    end
    
    if (nargout < 2)
        % Create the plot
        cax = newplot(cax);
        if isempty(sym),
            h = plot(x2,y2,'Parent',cax);
        else
            h = plot(x2,y2,sym,'Parent',cax);
        end
        if nargout==1, xo = h; end
    else
        xo = x2;
        yo = y2;
    end
end

function [pvpairs,args,nargs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    % check for LINESPEC
    if ~isempty(pvpairs)
        [l,c,m,tmsg]=colstyle(pvpairs{1},'plot');
        if isempty(tmsg)
            pvpairs = pvpairs(2:end);
            if ~isempty(l)
                pvpairs = {'LineStyle',l,pvpairs{:}};
            end
            if ~isempty(c)
                pvpairs = {'Color',c,pvpairs{:}};
            end
            if ~isempty(m)
                pvpairs = {'Marker',m,pvpairs{:}};
            end
        end
    end
    msg = checkpvpairs(pvpairs);
    nargs = length(args);
end