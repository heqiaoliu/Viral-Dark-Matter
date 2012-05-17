function [cout, hand] = contour(varargin)
    %CONTOUR Contour plot.
    %   CONTOUR(Z) is a contour plot of matrix Z treating the values in Z
    %   as heights above a plane.  A contour plot are the level curves
    %   of Z for some values V.  The values V are chosen automatically.
    %   CONTOUR(X, Y, Z) X and Y specify the (x, y) coordinates of the
    %   surface as for SURF. The X and Y data will be transposed or sorted
    %   to bring it to MESHGRID form depending on the span of the first
    %   row and column of X (to orient the data) and the order of the
    %   first row of X and the first column of Y (to sorted the data). The
    %   X and Y data must be consistently sorted in that if the first
    %   element of a column of X is larger than the first element of
    %   another column that all elements in the first column are larger
    %   than the corresponding elements of the second. Similarly Y must be
    %   consistently sorted along rows.
    %   CONTOUR(Z, N) and CONTOUR(X, Y, Z, N) draw N contour lines,
    %   overriding the automatic value.
    %   CONTOUR(Z, V) and CONTOUR(X, Y, Z, V) draw LENGTH(V) contour lines
    %   at the values specified in vector V.  Use CONTOUR(Z, [v, v]) or
    %   CONTOUR(X, Y, Z, [v, v]) to compute a single contour at the level v.
    %   CONTOUR(AX, ...) plots into AX instead of GCA.
    %   [C, H] = CONTOUR(...) returns contour matrix C as described in
    %   CONTOURC and a handle H to a contourgroup object.  This handle can
    %   be used as input to CLABEL.
    %
    %   The contours are normally colored based on the current colormap
    %   and are drawn as PATCH objects. You can override this behavior
    %   with the syntax CONTOUR(..., LINESPEC) to draw the contours
    %   with the color and linetype specified. See the help for PLOT
    %   for more information about LINESPEC values.
    %
    %   The above inputs to CONTOUR can be followed by property/value
    %   pairs to specify additional properties of the contour object.
    %
    %   Uses code by R. Pawlowicz to handle parametric surfaces and
    %   inline contour labels.
    %
    %   Example:
    %      [c, h] = contour(peaks); clabel(c, h); colorbar;
    %
    %   See also CONTOUR3, CONTOURF, CLABEL, COLORBAR, MESHGRID.
    
    %   Additional details:
    %
    %   CONTOUR uses CONTOUR3 to do most of the contouring.  Unless
    %   a linestyle is specified, CONTOUR will draw PATCH objects
    %   with edge color taken from the current colormap.  When a linestyle
    %   is specified, LINE objects are drawn.
    %
    %   Thanks to R. Pawlowicz (IOS) rich@ios.bc.ca for 'contours.m' and
    %   'clabel.m/inline_labels' so that contour now works with parametric
    %   surfaces and inline contour labels.
    
    %   Copyright 1984-2010 The MathWorks, Inc.
    %   $Revision: 5.18.4.21 $  $Date: 2010/03/31 18:24:49 $
    
    % First we check whether Handle Graphics uses MATLAB classes
    isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');
    
    % Next we check whether to use the V6 Plot API
    [v6, args] = usev6plotapi(varargin{:}, '-mfilename', mfilename);
    
    if isHGUsingMATLABClasses
        [c, h] = contourHGUsingMATLABClasses(args{:});
    else
        if v6
            [c, h] = Lcontourv6(args{:});
        else
            % Parse possible Axes input
            error(nargchk(1, Inf, nargin, 'struct'));
            [cax, args] = axescheck(args{:});
            [pvpairs, ~, msg] = parseargs(args);
            if ~isempty(msg)
                error(msg);
            end
            
            if isempty(cax) || ishghandle(cax, 'axes')
                cax = newplot(cax);
                parax = cax;
                hold_state = ishold(cax);
            else
                parax = cax;
                cax = ancestor(cax, 'axes');
                hold_state = true;
            end
            
            h = specgraph.contourgroup('Parent', parax, pvpairs{:});
            set(h, 'RefreshMode', 'auto');
            c = get(h, 'ContourMatrix');
            
            if ~hold_state
                view(cax, 2);
                set(cax, 'Box', 'on', 'Layer', 'top');
                grid(cax, 'off');
            end
            plotdoneevent(cax, h);
            h = double(h);
        end
    end
    
    if nargout > 0
        cout = c;
        hand = h;
    end
end

function [c, h] = Lcontourv6(varargin)
    % Parse possible Axes input
    error(nargchk(1, 6, nargin, 'struct'));
    [cax, args] = axescheck(varargin{:});
    
    cax = newplot(cax);
    
    [c, h, msg] = contour3(cax, args{:});
    if ~isempty(msg)
        error(msg);
    end
    
    set(h, 'ZData', []);
    
    if ~ishold(cax)
        view(cax, 2);
        set(cax, 'Box', 'on');
        grid(cax, 'off');
    end
end

function [pvpairs, args, msg] = parseargs(args)
    msg = '';
    % separate pv-pairs from opening arguments
    [args, pvpairs] = parseparams(args);
    
    % check for special string arguments trailing data arguments
    if ~isempty(pvpairs)
        [~, ~, ~, tmsg] = colstyle(pvpairs{1});
        if isempty(tmsg)
            args = [args, pvpairs(1)];
            pvpairs = pvpairs(2 : end);
        end
        msg = checkpvpairs(pvpairs);
    end
    
    nargs = length(args);
    x = [];
    y = [];
    z = [];
    if ischar(args{end})
        [l, c, ~, tmsg] = colstyle(args{end});
        if ~isempty(tmsg)
            msg = sprintf('Unknown option "%s".', args{end});
        end
        if ~isempty(c)
            pvpairs = [{'LineColor'}, {c}, pvpairs];
        end
        if ~isempty(l)
            pvpairs = [{'LineStyle'}, {l}, pvpairs];
        end
        nargs = nargs - 1;
    end
    if (nargs == 2) || (nargs == 4)
        if (nargs == 2)
            z = datachk(args{1});
            pvpairs = [{'ZData'}, {z}, pvpairs];
        else
            x = datachk(args{1});
            y = datachk(args{2});
            z = datachk(args{3});
            pvpairs = [{'XData'}, {x}, {'YData'}, {y}, {'ZData'}, {z}, pvpairs];
        end
        if (length(args{nargs}) == 1) && (fix(args{nargs}) == args{nargs})
            % N
            zmin = min(real(double(z(:))));
            zmax = max(real(double(z(:))));
            if args{nargs} == 1
                pvpairs = [{'LevelList'}, {(zmin + zmax) / 2}, pvpairs];
            else
                levs = linspace(zmin, zmax, args{nargs} + 2);
                pvpairs = [{'LevelList'}, {levs(2 : end - 1)}, pvpairs];
            end
        else
            % levels
            pvpairs = [{'LevelList'}, {unique(args{nargs})}, pvpairs];
        end
    elseif (nargs == 1)
        z = datachk(args{1});
        pvpairs = [{'ZData'}, {z}, pvpairs];
    elseif (nargs == 3)
        x = datachk(args{1});
        y = datachk(args{2});
        z = datachk(args{3});
        pvpairs = [{'XData'}, {x}, {'YData'}, {y}, {'ZData'}, {z}, pvpairs];
    end
    % Make sure that the data is consistent if x and y are specified.
    if ~isempty(x)
        msg = xyzcheck(x, y, z);
    end
    if ~isempty(z) && isempty(msg)
        k = find(isfinite(z));
        zmax = max(z(k));
        zmin = min(z(k));
        if ~any(k)
            warning('MATLAB:contour:NonFiniteData', 'Contour not rendered for non-finite ZData');
        elseif isempty(z) || (zmax == zmin)
            warning('MATLAB:contour:ConstantData', 'Contour not rendered for constant ZData');
        end
    end
    args = [];
end
