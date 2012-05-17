function hh = clabel(cs, varargin)
    %CLABEL Contour plot elevation labels.
    %   CLABEL(CS, H) adds height labels to the contour plot specified by H.
    %   The labels are rotated and inserted within the contour lines.  CS and H
    %   are the contour matrix output and object handle outputs from CONTOUR,
    %   CONTOUR3, or CONTOURF.
    %
    %   CLABEL(CS, H, V) labels just those contour levels given in
    %   vector V.  The default action is to label all known contours.
    %   The label positions are selected randomly.
    %
    %   CLABEL(CS, H, 'manual') places contour labels at the locations
    %   clicked on with a mouse.  Pressing the return key terminates
    %   labeling.  Use the space bar to enter contours and the arrow
    %   keys to move the crosshair if no mouse is available.
    %
    %   CLABEL(CS) or CLABEL(CS, V) or CLABEL(CS, 'manual') places
    %   contour labels as above, except that the labels are drawn as
    %   plus signs on the contour with a nearby height value.
    %
    %   H = CLABEL(...) returns handles to the TEXT (and possibly LINE)
    %   objects in H.  The UserData property of the TEXT objects contain
    %   the height value for each label.
    %
    %   CLABEL(..., 'text property', property_value, ...) allows arbitrary
    %   TEXT property/value pairs to specified for the label strings.
    %
    %   One special property ('LabelSpacing') is also available to specify
    %   the spacing between labels (in points). This defaults to 144, or
    %   2 inches.
    %
    %   Uses code by R. Pawlowicz to handle inline contour labels.
    %
    %   Example
    %      subplot(1, 3, 1); [cs, h] = contour(peaks); clabel(cs, h, 'labelspacing', 72);
    %      subplot(1, 3, 2); cs = contour(peaks); clabel(cs);
    %      subplot(1, 3, 3); [cs, h] = contour(peaks);
    %      clabel(cs, h, 'FontSize', 15, 'Color', 'r', 'Rotation', 0);
    %
    %   See also CONTOUR, CONTOUR3, CONTOURF.
    
    %   Thanks to R. Pawlowicz (IOS) rich@ios.bc.ca for the algorithm used
    %   in 'inline_labels' so that clabel can produce inline labeling.
    
    %   Copyright 1984-2010 The MathWorks, Inc.
    %   $Revision: 5.38.4.19 $  $Date: 2010/03/31 18:24:47 $
    
    % Modified by R Pawlowicz to allow for text properties as in
    % extcontour code 14/5/97
    % 28/10/97 - modified to work in map contouring
    %  9/01/98 - improved calculation of gaps for line labels
    %   Fix by Eric Firing, efiring@soest.hawaii.edu, 4/97, to
    %   make the rotation angles correct when XDir and/or YDir are
    %   reverse.
    
    % First we check whether Handle Graphics uses MATLAB classes
    isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');
    
    if isHGUsingMATLABClasses
        h = clabelHGUsingMATLABClasses(cs, varargin{:});
    else
        error(nargchk(1, Inf, nargin, 'struct'));
        if min(size(cs)) > 2
            error(id('InvalidContourMatrixInput'), ...
                'First input must be a valid contour description matrix.');
        end

        firstArgValidObj = ~isempty(varargin) && ...
            ishghandle(varargin{1}(1)) && ...
            (strcmp(get(varargin{1}(1), 'Type'), 'line') || ...
            strcmp(get(varargin{1}(1), 'Type'), 'patch') || ...
            isa(handle(varargin{1}(1)), 'specgraph.contourgroup'));
        
        if firstArgValidObj
            cax = ancestor(varargin{1}(1), 'axes');
        else
            cax = gca;
        end

        threeD = IsThreeD(cax);

        if nargin == 1
            h = plus_labels(cax, threeD, cs);
        else
            if firstArgValidObj
                if isa(handle(varargin{1}), 'specgraph.contourgroup') && ...
                        ~any(strcmpi(varargin, 'manual'))
                    ch = varargin{1};
                    varargin(1) = [];
                    set(ch, 'ShowText', 'on');
                    if ~isempty(varargin) && isnumeric(varargin{1})
                        set(ch, 'TextList', varargin{1});
                        varargin(1) = [];
                    end
                    for k = 1 : length(varargin)
                        if strncmpi(varargin{k}, 'lab', 3)
                            set(ch, 'LabelSpacing', varargin{k + 1});
                            varargin(k : k + 1) = [];
                            break
                        end
                    end
                    h = findobj(ch, 'Type', 'text');
                    if ~isempty(varargin)
                        set(h, varargin{:});
                    end
                else
                    if isa(handle(varargin{1}), 'specgraph.contourgroup')
                        varargin{1} = get(varargin{1}, 'Children');
                        varargin{1} = flipud(findobj(varargin{1}, 'flat', 'Type', 'patch'));
                    end
                    h = inline_labels(cax, cs, varargin{:});
                end
            else
                h = plus_labels(cax, threeD, cs, varargin{:});
            end
        end

        if ishghandle(cax) && ~ishold(cax)
            if threeD
                view(cax, 3);
            else
                view(cax, 2);
            end
        end
    end
    
    if nargout > 0
        hh = h;
    end
end

function H = inline_labels(cax, CS, h, varargin)
    %
    % Draw the labels along the contours and rotated to match the local slope.
    %
    
    % To open up space in the contours, we rely on the order in which
    % the handles h are created in CONTOUR3.  If CONTOUR3 changes you
    % might need to change the algorithm below.
    
    % Author: R. Pawlowicz IOS rich@ios.bc.ca
    %         12/12/94
    %         changes - R. Pawlowicz 14/5/97 - small bug in "that ole'
    %         matlab magic" fixed, also another in manual selection
    %         of locations.
    
    manual = 0;
    v = [];
    inargs = zeros(1, length(varargin));
    
    if nargin >= 4 && strcmp(varargin{1}, 'manual')
        manual = 1;
        inargs(1) = 1;
    end
    
    if ~manual && nargin >= 4 && ~ischar(varargin{1})
        v = varargin{1};
        inargs(1) = 1;
    end
    
    lab_int = 72 * 2;  % label interval (points)
    
    for k = find(inargs == 0)
        if strncmpi(varargin{k}, 'lab', 3)
            inargs([k, k + 1]) = 1;
            lab_int = varargin{k + 1};
        end
    end
    
    varargin(inargs ~= 0) = [];
    
    if strcmp(get(h(1), 'Type'), 'patch') && ~strcmp(get(h(1), 'FaceColor'), 'none')
        isfilled = 1;
    else
        isfilled = 0;
    end
    
    if (strcmp(get(cax, 'XDir'), 'reverse'))
        XDir = -1;
    else
        XDir = 1;
    end
    if (strcmp(get(cax, 'YDir'), 'reverse'))
        YDir = -1;
    else
        YDir = 1;
    end
    
    % Compute scaling to make sure printed output looks OK. We have to go via
    % the figure's 'paperposition', rather than the absolute units of the
    % axes 'position' since those would be absolute only if we kept the 'units'
    % property in some absolute units (like 'points') rather than the default
    % 'normalized'.
    
    UN = get(cax, 'Units');
    parent = get(cax, 'Parent');
    if strcmp(UN, 'normalized') && strcmp(get(parent, 'Type'), 'figure')
        UN = get(parent, 'PaperUnits');
        set(parent, 'PaperUnits', 'points');
        PA = get(parent, 'PaperPosition');
        set(parent, 'PaperUnits', UN);
        PA = PA .* get(cax, 'Position');
    else
        set(cax, 'Units', 'points');
        PA = get(cax, 'Position');
        set(cax, 'Units', UN);
    end
    
    % Find beginning of all lines
    
    lCS = size(CS, 2);
    
    if ~isempty(get(cax, 'Children'))
        XL = get(cax, 'XLim');
        YL = get(cax, 'YLim');
    else
        iL = [];
        k = 1;
        XL = [Inf, -Inf];
        YL = [Inf, -Inf];
        while (k < lCS)
            x = CS(1, k + (1 : CS(2, k)));
            y = CS(2, k + (1 : CS(2, k)));
            XL = [min([XL(1), x]), max([XL(2), x])];
            YL = [min([YL(1), y]), max([YL(2), y])];
            iL = [iL, k]; %#ok<AGROW>
            k = k + CS(2, k) + 1;
        end
        set(cax, 'XLim', XL, 'YLim', YL);
    end
    
    Aspx = PA(3) / diff(XL);  % To convert data coordinates to paper (we need to do this
    Aspy = PA(4) / diff(YL);  % to get the gaps for text the correct size)
    
    H = [];
    
    % Set up a dummy text object from which you can get text extent info
    H1 = text(XL(1), YL(1), 'dummyarg', 'Parent', cax, 'Units', 'points', 'Visible', 'off', varargin{:});
    
    % Decompose contour data structure if manual mode.
    
    if manual
        disp(' ')
        disp('    Please wait a moment...')
        x = [];
        y = [];
        ilist = [];
        klist = [];
        plist = [];
        ii = 0;
        k = 0;
        n = 0;
        while (1)
            k = k + 1;
            ii = ii + n + 1;
            if ii > lCS
                break
            end
            n = CS(2, ii);
            nn = 2 .* n - 1;
            xtemp = zeros(nn, 1);
            ytemp = zeros(nn, 1);
            xtemp(1 : 2 : nn) = CS(1, ii + 1 : ii + n);
            xtemp(2 : 2 : nn) = (xtemp(1 : 2 : nn - 2) + xtemp(3 : 2 : nn)) ./ 2;
            ytemp(1 : 2 : nn) = CS(2, ii + 1 : ii + n);
            ytemp(2 : 2 : nn) = (ytemp(1 : 2 : nn - 2) + ytemp(3 : 2 : nn)) ./ 2;
            x = [x; xtemp]; %#ok<AGROW>
            y = [y; ytemp]; %#ok<AGROW>
            ilist = [ilist; ii(ones(nn, 1))]; %#ok<AGROW>
            klist = [klist; k(ones(nn, 1))]; %#ok<AGROW>
            plist = [plist; (1 : .5 : n)']; %#ok<AGROW>
        end
        ax = axis;
        xmin = ax(1);
        xmax = ax(2);
        ymin = ax(3);
        ymax = ax(4);
        xrange = xmax - xmin;
        yrange = ymax - ymin;
        xylist = (x .* yrange + sqrt(-1) .* y .* xrange);
        view(cax, 2);
        disp(' ')
        disp('   Carefully select contours for labeling.')
        disp('   When done, press RETURN while the Graph window is the active window.')
    end
    
    % Get labels all at once to get the length of the longest string.
    % This allows us to call extent only once, thus speeding up this routine
    if ~manual
        labels = getlabels(CS);
        % Get the size of the label
        set(H1, 'String', repmat('9', 1, size(labels, 2)), 'Visible', 'on', varargin{:});
        EX = get(H1, 'Extent');
        set(H1, 'Visible', 'off');
    end
    
    ii = 1;
    k = 0;
    while (ii < lCS)
        if manual
            try
                [xx, yy, button] = ginput(1);
            catch err %#ok<NASGU>
                return
            end
            if isempty(button) || isequal(button, 13)
                break
            end
            if xx < xmin || xx > xmax
                break
            end
            if yy < ymin || yy > ymax
                break
            end
            xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
            dist = abs(xylist - xy);
            [~, f] = min(dist);
            if ~isempty(f)
                f = f(1);
                ii = ilist(f);
                k = klist(f);
                p = floor(plist(f));
            end
        else
            k = k + 1;
        end
        
        if ~isfilled && k > length(h)
            error(id('ContourHandleInputs'), 'Not enough contour handles.');
        end
        
        l = CS(2, ii);
        x = CS(1, ii + (1 : l));
        y = CS(2, ii + (1 : l));
        
        lvl = CS(1, ii);
        
        if manual
            lab = num2str(lvl);
            % Get the size of the label
            set(H1, 'String', lab, 'Visible', 'on', varargin{:});
            EX = get(H1, 'Extent');
            set(H1, 'Visible', 'off');
            len_lab = EX(3) / 2;
        else
            %RP - get rid of all blanks in label
            lab = labels(k, labels(k, :) ~= ' ');
            %RP - scale label length by string size instead of a fixed length
            len_lab = EX(3) / 2 * length(lab) / size(labels, 2);
        end
        
        % RP28/10/97 - Contouring sometimes returns x vectors with
        % NaN in them - we want to handle this case!
        sx = x * Aspx;
        sy = y * Aspy;
        d = [0, sqrt(diff(sx) .^ 2 + diff(sy) .^ 2)];
        % Determine the location of the NaN separated sections
        section = cumsum(isnan(d));
        d(isnan(d)) = 0;
        d = cumsum(d);
        
        if ~manual
            len_contour = max(0, d(l) - 3 * len_lab);
            slop = (len_contour - floor(len_contour / lab_int) * lab_int);
            start = 1.5 * len_lab + max(len_lab, slop) * rands(1); % Randomize start
            psn = start : lab_int : d(l) - 1.5 * len_lab;
        else
            psn = min(max(max(d(p), d(2) + eps * d(2)), d(1) + len_lab), d(end) - len_lab);
            psn = max(0, min(psn, max(d)));
        end
        oldbreaks = getappdata(h(k), 'LevelBreaks');
        [psn, psnI] = sort([oldbreaks, psn]);
        setappdata(h(k), 'LevelBreaks', psn);
        lp = size(psn, 2);
        
        if (lp > 0) && isfinite(lvl) && ...
                (isempty(v) || any(abs(lvl - v) / max(eps + abs(v)) < .00001))
            
            Ic = sum(d(ones(1, lp), :)' < psn(ones(1, l), :), 1);
            Il = sum(d(ones(1, lp), :)' <= psn(ones(1, l), :) - len_lab, 1);
            Ir = sum(d(ones(1, lp), :)' < psn(ones(1, l), :) + len_lab, 1);
            
            % Check for and handle out of range values
            out = (Ir < 1 | Ir > length(d) - 1) | ...
                (Il < 1 | Il > length(d) - 1) | ...
                (Ic < 1 | Ic > length(d) - 1);
            Ir = max(1, min(Ir, length(d) - 1));
            Il = max(1, min(Il, length(d) - 1));
            Ic = max(1, min(Ic, length(d) - 1));
            
            % For out of range values, don't remove datapoints under label
            Il(out) = Ic(out);
            Ir(out) = Ic(out);
            
            % Remove label if it isn't in the same section
            bad = (section(Il) ~= section(Ir));
            Il(bad) = [];
            Ir(bad) = [];
            Ic(bad) = [];
            psn(:, bad) = [];
            out(bad) = [];
            lp = length(Il);
            in = ~out;
            
            if ~isempty(Il)
                
                % Endpoints of text in data coordinates
                wl = (d(Il + 1) - psn + len_lab .* in) ./ (d(Il + 1) - d(Il));
                wr = (psn - len_lab .* in - d(Il)) ./ (d(Il + 1) - d(Il));
                xl = x(Il) .* wl + x(Il + 1) .* wr;
                yl = y(Il) .* wl + y(Il + 1) .* wr;
                
                wl = (d(Ir + 1) - psn - len_lab .* in) ./ (d(Ir + 1) - d(Ir));
                wr = (psn + len_lab .* in - d(Ir)) ./ (d(Ir + 1) - d(Ir));
                xr = x(Ir) .* wl + x(Ir + 1) .* wr;
                yr = y(Ir) .* wl + y(Ir + 1) .* wr;
                
                trot = atan2((yr - yl) * YDir * Aspy, (xr - xl) * XDir * Aspx) * 180 / pi;
                backang = abs(trot) > 90;
                trot(backang) = trot(backang) + 180;
                
                % Text location in data coordinates
                wl = (d(Ic + 1) - psn) ./ (d(Ic + 1) - d(Ic));
                wr = (psn - d(Ic)) ./ (d(Ic + 1) - d(Ic));
                xc = x(Ic) .* wl + x(Ic + 1) .* wr;
                yc = y(Ic) .* wl + y(Ic + 1) .* wr;
                
                % Shift label over a little if in a curvy area
                shiftfrac = .5;
                
                xc = xc * (1 - shiftfrac) + (xr + xl) / 2 * shiftfrac;
                yc = yc * (1 - shiftfrac) + (yr + yl) / 2 * shiftfrac;
                
                % Remove data points under the label...
                % First, find endpoint locations as distances along lines
                
                dr = d(Ir) + sqrt(((xr - x(Ir)) * Aspx) .^ 2 + ((yr - y(Ir)) * Aspy) .^ 2);
                dl = d(Il) + sqrt(((xl - x(Il)) * Aspx) .^ 2 + ((yl - y(Il)) * Aspy) .^ 2);
                
                f1 = accumarray([ones(lp, 1), Il.'], ones(1, lp), [1, l]);
                f2 = accumarray([ones(lp, 1), Ir.'], ones(1, lp), [1, l]);
                irem = find(cumsum(f1) - cumsum(f2)) + 1;
                x(irem) = [];
                y(irem) = [];
                d(irem) = [];
                l = l - size(irem, 2);
                
                % Put the points in the correct order...
                
                xf = [x(1 : l), xl, NaN(size(xc)), xr];
                yf = [y(1 : l), yl, yc, yr];
                
                [~, If] = sort([d(1 : l), dl, psn, dr]);
                
                % ...and draw.
                %
                % Here's where we assume the order of the h(k).
                %
                z = get(h(k), 'ZData');
                if ~isfilled % Only modify lines or patches if unfilled
                    % Handle contour3 case (z won't be empty).
                    if isempty(z)
                        set(h(k), 'XData', [xf(If), NaN], 'YData', [yf(If), NaN]);
                        if strcmp(get(h(k), 'Type'), 'patch')
                            set(h(k), 'CData', lvl + [0 * xf(If), NaN]);
                        end
                    else
                        xd = [xf(If), NaN];
                        set(h(k), ...
                            'XData', xd, 'YData', [yf(If), NaN], ...
                            'ZData', z(1) + 0 * xd);
                        if strcmp(get(h(k), 'Type'), 'patch')
                            set(h(k), 'CData', lvl + [0 * xf(If), NaN]);
                            if size(get(h(k), 'Vertices'), 1) ~= size(get(h(k), 'FaceVertexCData'), 1)
                                verts = get(h(k), 'Vertices');
                                set(h(k), 'Vertices', verts(1 : end - 1, :));
                            end
                        end
                    end
                end
                
                for jj = 1 : lp
                    if psnI(jj) <= length(oldbreaks)
                        continue
                    end
                    % Handle contour3 case (z won't be empty).
                    if ~isempty(z)
                        H = [H; text(xc(jj), yc(jj), z(1), lab, 'Parent', cax, 'Rotation', trot(jj), ...
                            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', ...
                            'Clipping', 'on', ...
                            'UserData', lvl, varargin{:})]; %#ok<AGROW>
                    else
                        H = [H; text(xc(jj), yc(jj), lab, 'Parent', cax, 'Rotation', trot(jj), ...
                            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', ...
                            'Clipping', 'on', ...
                            'UserData', lvl, varargin{:})]; %#ok<AGROW>
                    end
                end
            end
        else
            if ~isfilled % Only modify lines or patches if unfilled
                
                %
                % Here's another place where we assume the order of the h(k)
                %
                set(h(k), 'XData', [x, NaN], 'YData', [y, NaN]);
                
                % Handle contour3 case (z won't be empty).
                z = get(h(k), 'ZData');
                if ~isempty(z)
                    set(h(k), 'ZData', []); % Work around for bug in face generation
                    
                    % Set z to a constant while preserving the location of NaN's
                    set(h(k), 'ZData', z(1) + 0 * get(h(k), 'XData'));
                end
                if strcmp(get(h(k), 'Type'), 'patch')
                    set(h(k), 'CData', lvl + [0 * x, NaN]);
                end
            end
        end
        
        if ~manual
            ii = ii + 1 + CS(2, ii);
        end
    end
    
    % delete dummy string
    delete(H1);
end

function h = plus_labels(cax, threeD, cs, varargin)
    %
    % Draw the labels as plus symbols next to text (v4 compatible)
    %
    
    %    RP - 14/5/97
    %    Clay M. Thompson 6-7-96
    %    Charles R. Denham, MathWorks, 1988, 1989, 1990.
    manual = 0;
    choice = 0;
    
    if nargin > 3
        if ischar(varargin{1})
            if strcmp(varargin{1}, 'manual')
                varargin(1) = [];
                manual = 1;
            end
        else
            choice = 1;
            v = sort(varargin{1}(:));
            varargin(1) = [];
        end
    end
    
    ncs = size(cs, 2);
    
    % Find range of levels.
    k = 1;
    i = 1;
    while k <= ncs
        levels(i) = cs(1, k); %#ok<AGROW>
        i = i + 1;
        k = k + cs(2, k) + 1;
    end
    crange = max(abs(levels));
    cdelta = abs(diff(levels));
    cdelta = min(cdelta(cdelta > eps)) / max(eps, crange); % Minimum significant change
    if isempty(cdelta)
        cdelta = 0;
    end
    
    % Decompose contour data structure if manual mode.
    
    if manual
        disp(' ')
        disp('    Please wait a moment...')
        x = [];
        y = [];
        clist = [];
        k = 0;
        n = 0;
        while (1)
            k = k + n + 1;
            if k > ncs
                break
            end
            c = cs(1, k);
            n = cs(2, k);
            nn = 2 .* n - 1;
            xtemp = zeros(nn, 1);
            ytemp = zeros(nn, 1);
            xtemp(1 : 2 : nn) = cs(1, k + 1 : k + n);
            xtemp(2 : 2 : nn) = (xtemp(1 : 2 : nn - 2) + xtemp(3 : 2 : nn)) ./ 2;
            ytemp(1 : 2 : nn) = cs(2, k + 1 : k + n);
            ytemp(2 : 2 : nn) = (ytemp(1 : 2 : nn - 2) + ytemp(3 : 2 : nn)) ./ 2;
            x = [x; xtemp]; %#ok<AGROW>
            y = [y; ytemp]; %#ok<AGROW>
            clist = [clist; c .* ones(2 * n - 1, 1)]; %#ok<AGROW>
        end
        ax = axis;
        xmin = ax(1);
        xmax = ax(2);
        ymin = ax(3);
        ymax = ax(4);
        xrange = xmax - xmin;
        yrange = ymax - ymin;
        xylist = (x .* yrange + sqrt(-1) .* y .* xrange);
        view(cax, 2);
        disp(' ')
        disp('   Carefully select contours for labeling.')
        disp('   When done, press RETURN while the Graph window is the active window.')
    end
    
    k = 0;
    n = 0;
    flip = 0;
    h = [];
    
    while (1)
        
        % Use GINPUT and select nearest point if manual.
        
        if manual
            try
                [xx, yy, button] = ginput(1);
            catch err %#ok<NASGU>
                return
            end
            if isempty(button) || isequal(button, 13)
                break
            end
            if xx < xmin || xx > xmax
                break
            end
            if yy < ymin || yy > ymax
                break
            end
            xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
            dist = abs(xylist - xy);
            [~, f] = min(dist);
            if ~isempty(f)
                f = f(1);
                xx = x(f);
                yy = y(f);
                c = clist(f);
                okay = 1;
            else
                okay = 0;
            end
        end
        
        % Select a labeling point randomly if not manual.
        
        if ~manual
            k = k + n + 1;
            if k > ncs
                break
            end
            c = cs(1, k);
            n = cs(2, k);
            if choice
                f = find(abs(c - v) / max(eps + abs(v)) < .00001, 1);
                okay = ~isempty(f);
            else
                okay = 1;
            end
            if okay
                r = rands(1);
                j = fix(r .* (n - 1)) + 1;
                if flip
                    j = n - j;
                end
                flip = ~flip;
                if n == 1    % if there is only one point
                    xx = cs(1, j + k);
                    yy = cs(2, j + k);
                else
                    x1 = cs(1, j + k);
                    y1 = cs(2, j + k);
                    x2 = cs(1, j + k + 1);
                    y2 = cs(2, j + k + 1);
                    xx = (x1 + x2) ./ 2;
                    yy = (y1 + y2) ./ 2;  % Test was here; removed.
                end
            end
        end
        
        % Label the point.
        
        if okay
            % Set tiny labels to zero.
            if abs(c) <= 10 * eps * crange
                c = 0;
            end
            % Determine format string number of digits
            if cdelta > 0
                ndigits = max(3, ceil(-log10(cdelta)));
            else
                ndigits = 3;
            end
            s = num2str(c, ndigits);
            hl = line('XData', xx, 'YData', yy, 'Marker', '+', 'EraseMode', 'none');
            ht = text(xx, yy, s, 'Parent', cax, 'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', 'left', 'EraseMode', 'none', ...
                'Clipping', 'on', 'UserData', c, varargin{:});
            if threeD
                set(hl, 'ZData', c);
                set(ht, 'Position', [xx, yy, c]);
            end
            h = [h; hl]; %#ok<AGROW>
            h = [h; ht]; %#ok<AGROW>
        end
    end
end

function labels = getlabels(CS)
    %GETLABELS Get contour labels
    v = [];
    i = 1;
    while i < size(CS, 2)
        v = [v, CS(1, i)]; %#ok<AGROW>
        i = i + CS(2, i) + 1;
    end
    labels = num2str(v');
end

function threeD = IsThreeD(cax)
    %ISTHREED  True for a contour3 plot
    hp = findobj(cax, 'Type', 'patch');
    if isempty(hp)
        hp = findobj(cax, 'Type', 'line');
    end
    if ~isempty(hp)
        % Assume a contour3 plot if z data not empty
        threeD = ~isempty(get(hp(1), 'ZData'));
    else
        threeD = 0;
    end
end

function r = rands(sz)
    %RANDS Uniform random values without affecting the global stream
    dflt = RandStream.getDefaultStream();
    savedState = dflt.State;
    r = rand(sz);
    dflt.State = savedState;
end

function str = id(str)
    str = ['MATLAB:clabel:' str];
end
