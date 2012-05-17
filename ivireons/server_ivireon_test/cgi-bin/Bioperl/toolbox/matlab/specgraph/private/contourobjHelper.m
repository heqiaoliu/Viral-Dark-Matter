function varargout = contourobjHelper(functionName, varargin)
    % This function is undocumented and may change in a future release.
    
    %   Copyright 2010 The MathWorks, Inc.
    
    % Switchyard for helper functions used by the CONTOUR command.
    %   Function name may be one of:
    %      parseargs - Parses input args into pvpairs
    %      addListeners - Sets up the necessary callbacks
    %      updateAxesLimits - Updates axes limits
    
    error(nargchk(1, inf, nargin, 'struct'));
    
    if ~ischar(functionName)
        error('MATLAB:contourobjHelper:firstInputString', 'The first input argument must be a string.');
    end
    
    switch(functionName)
        case 'parseargs'
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = localParseargs(varargin{:});
        case 'addListeners'
            localAddListeners(varargin{:});
        case 'updateAxesLimits'
            localUpdateAxesLimits(varargin{:});
        case 'contourLabelScaleParams'
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}] = localContourLabelScaleParams(varargin{:});
        case 'contourLabelRenderParams'
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}] = localContourLabelRenderParams(varargin{:});
    end
end

function [pvpairs, args, nargs, msg] = localParseargs(varargin)
    
    bmin = varargin{1};
    args = varargin(2 : end);
    
    % Initialize output message.
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
    
    % treat any special string arguments as pvpairs
    nargs = length(args);
    if nargs > 0 && ischar(args{end})
        [lStyle, lColor, ~, tmsg] = colstyle(args{end});
        if ~isempty(tmsg)
            msg = sprintf('Unknown option "%s".', args{end});
        end
        if ~isempty(lColor)
            pvpairs = [{'LineColor'}, {lColor}, pvpairs];
        end
        if ~isempty(lStyle)
            pvpairs = [{'LineStyle'}, {lStyle}, pvpairs];
        end
        nargs = nargs - 1;
    end
    
    if nargs == 0
        % Create a default contour for the 0-arg case.  Leave XData and YData in auto mode.
        pvpairs = [{'XData_I'}, {1 : 3}, {'YData_I'}, {1 : 3}, {'ZData'}, {eye(3)}, pvpairs];
        args = [];
        return
    end
    
    % Initialize x, y, z, l.
    x = [];
    y = [];
    z = [];
    l = [];
    
    % Convert args to full double, and throw error otherwise
    larg = false;
    if (nargs == 3) || (nargs == 4)
        % C = CONTOUR(X, Y, Z)
        % C = CONTOUR(X, Y, Z, N)
        % C = CONTOUR(X, Y, Z, V)
        
        x = datachk(args{1});
        y = datachk(args{2});
        z = datachk(args{3});
        if (nargs == 4)
            l = datachk(args{4});
            larg = true;
        end
    elseif (nargs == 1) || (nargs == 2)
        % C = CONTOUR(Z)
        % C = CONTOUR(Z, N)
        % C = CONTOUR(Z, V)
        
        z = datachk(args{1});
        if (nargs == 2)
            l = datachk(args{2});
            larg = true;
        end
    end
    
    % Check args for real and at most 2D, and throw error otherwise
    for i = 1 : nargs
        if ~isreal(args{i})
            error('MATLAB:Contour:InputsMustBeReal', 'Input arguments for contour must be real');
        end
        if ndims(args{i}) > 2
            error('MATLAB:Contour:InputsMustHaveAtMost2Dimensions', 'Input arguments for contourc must have at most 2 dimensions');
        end
    end
    
    % For back compatibility, errors after this point are suppressed into
    % the output message.
    
    % Check that non-empty z is at least a 2x2 matrix.  Note that isvector
    % returns true for a scalar.
    if ~isempty(z) && isvector(z)
        msg = makemsg( ...
            'MATLAB:Contour:ZMustBeAtLeast2x2Matrix', ...
            'Z must be at least a 2x2 matrix.');
        return;
    end
    
    % Check that non-empty x, y are not scalars.
    if isscalar(x)
        msg = makemsg( ...
            'MATLAB:Contour:XMustNotBeScalar', ...
            'X must not be a scalar.');
        return;
    end
    if isscalar(y)
        msg = makemsg( ...
            'MATLAB:Contour:YMustNotBeScalar', ...
            'Y must not be a scalar.');
        return;
    end
    
    % Check that non-empty l is a vector or a scalar.
    if ~isempty(l) && ~isvector(l)
        msg = makemsg( ...
            'MATLAB:Contour:LMustBeVectorOrScalar', ...
            'Contour level values must be a vector or a scalar.');
        return;
    end
    
    % Check the relative sizes and lengths of X, Y, and Z
    if (nargs > 2)
        if isempty(z)
            if (~isempty(x) && ~isempty(y))
                msg = makemsg( ...
                    'MATLAB:Contour:LengthOfXandYMustMatchColsAndRowsInZ', ...
                    'Lengths of X and Y must match number of cols and rows in Z, respectively.');
                return;
            elseif ~isempty(x)
                msg = makemsg( ...
                    'MATLAB:Contour:LengthOfXMustMatchColsInZ', ...
                    'Length of X must match number of cols in Z.');
                return;
            elseif ~isempty(y)
                msg = makemsg( ...
                    'MATLAB:Contour:LengthOfYMustMatchRowsInZ', ...
                    'Length of Y must match number of rows in Z.');
                return;
            end
        else
            msg = xyzcheck(x, y, z);
            if ~isempty(msg)
                return
            end
        end
    end
    
    if ~isempty(find(~isfinite(x), 1))
        msg = makemsg( ...
            'MATLAB:Contour:XMustBeFinite', ...
            'X values must be finite.');
        return;
    end
    
    if ~isempty(find(~isfinite(y), 1))
        msg = makemsg( ...
            'MATLAB:Contour:YMustBeFinite', ...
            'Y values must be finite.');
        return;
    end
    
    if ~isempty(find(~isfinite(l), 1))
        msg = makemsg( ...
            'MATLAB:Contour:LMustBeFinite', ...
            'Contour level values must be finite.');
        return;
    end
    
    if isvector(x)
        diffx = diff(x);
        if any(diffx <= 0) && any(diffx >= 0)
            msg = makemsg( ...
                'MATLAB:Contour:VectorXMustBeUniqueMonotone', ...
                'Vector X must be unique and monotone.');
            return;
        end
    end
    
    if isvector(y)
        diffy = diff(y);
        if any(diffy <= 0) && any(diffy >= 0)
            msg = makemsg( ...
                'MATLAB:Contour:VectorYMustBeUniqueMonotone', ...
                'Vector Y must be unique and monotone.');
            return;
        end
    end
    
    % Size calculations
    nLevels = 0;
    nl = numel(l);
    if nl > 0
        if (nl == 1)
            nLevels = l(1);
            if (nLevels < 0)
                msg = makemsg( ...
                    'MATLAB:Contour:NMustNotBeNegative', ...
                    'Number of contour levels must not be negative.');
                return;
            end
            nLevels = fix(nLevels);
        elseif (nl == 2) && (l(1) == l(2))
            nLevels = 1;
        else
            if any(diff(l) <= 0)
                msg = makemsg( ...
                    'MATLAB:Contour:VMustBeUniqueSortedIncreasing', ...
                    'Contour levels must be unique, sorted, and increasing.');
                return;
            end
            nLevels = nl;
        end
    end
    
    % Early exit with empty output when Z is empty.
    if isempty(z)
        return
    end
    
    % Calculate the min and max values of Z, ignoring NaNs and Infs.
    k = find(isfinite(z));
    zmin = min(z(k));
    zmax = max(z(k));
    
    % Early exit with empty output when Z is all non-finite (i.e., entirely NaNs and/or Infs).
    % Early exit with empty output when Z is constant (i.e., when zmin == zmax).
    if (~any(k) || (zmin == zmax))
        return
    end
    
    % Set up pvpairs for X, Y, Z.
    if (nargs > 2)
        pvpairs = [{'XData'}, {x}, {'YData'}, {y}, {'ZData'}, {z}, pvpairs];
        args(1 : 3) = [];
        nargs = nargs - 3;
    else
        % Leave XData and YData in auto mode.
        [zm, zn] = size(z);
        pvpairs = [{'XData_I'}, {1 : zn}, {'YData_I'}, {1 : zm}, {'ZData'}, {z}, pvpairs];
        args(1) = [];
        nargs = nargs - 1;
    end
    
    % Set up pvpairs for LevelList.
    if larg
        if (nl == 1)
            if nLevels == 1
                levels = (zmin + zmax) / 2;
            else
                levels = linspace(zmin, zmax, nLevels + 2);
                levels = levels(2 : end - 1);
            end
            if bmin
                levels = [zmin, levels];
            end
        else
            levels = l(1 : nLevels);
        end
        pvpairs = [{'LevelList'}, {levels}, pvpairs];
        args(1) = [];
        nargs = nargs - 1;
    end
end

function msg = makemsg(id, str)
    msg.identifier = id;
    msg.message = str;
end

function localAddListeners(hAx, hContour)
    if ~isempty(hAx)
        addlistener(hAx, 'MarkedDirty', @(obj, evd) localUpdateAxesLimits(obj, hContour));
        addlistener(hAx, 'ObjectBeingDestroyed', @(obj, evd) localAxesObjectBeingDestroyed(hContour));
    end
end

function localAxesObjectBeingDestroyed(hContour)
    delete(hContour);
end

function localUpdateAxesLimits(hAx, hContour)
    % Protect against empty handles.
    if isempty(hAx) || isempty(hContour)
        return
    end
    
    ch = getDescendantNonGroupChildren(hAx);
    numch = numel(ch);
    onlyChild = numch == 1 && isequal(hContour, ch(1));
    
    % Since tight limits aren't part of axes state we have to set
    % them explicitly even though limits might be in manual mode.
    % Determine whether we should update limits based on 'auto' modes
    % or if the limits agree with the old limits contour wanted to use
    % and we are the only child in this object.
    if onlyChild
        oldXLim = getappdata(hAx, 'ContourXLim');
        oldYLim = getappdata(hAx, 'ContourYLim');
        xLimOverwritable = strcmp(get(hAx, 'XLimMode'), 'auto') || ...
            (~isempty(oldXLim) && isequal(oldXLim, get(hAx, 'XLim')));
        yLimOverwritable = strcmp(get(hAx, 'YLimMode'), 'auto') || ...
            (~isempty(oldYLim) && isequal(oldYLim, get(hAx, 'YLim')));
        if xLimOverwritable && yLimOverwritable
            xData = hContour.XData;
            yData = hContour.YData;
            % xData and yData are either both empty ot both not empty.
            if ~isempty(xData) && ~isempty(yData)
                xmin = min(xData(:));
                xmax = max(xData(:));
                ymin = min(yData(:));
                ymax = max(yData(:));
                if xmin == xmax
                    xmin = xmin - 1;
                    xmax = xmax + 1;
                end
                if ymin == ymax
                    ymin = ymin - 1;
                    ymax = ymax + 1;
                end
                xLims = [xmin, xmax];
                yLims = [ymin, ymax];
                set(hAx, 'XLim', xLims, 'YLim', yLims);
                setappdata(hAx, 'ContourXLim', xLims);
                setappdata(hAx, 'ContourYLim', yLims);
            end
        end
    end
end

function out = getDescendantNonGroupChildren(p)
    ch = p.Children;
    if isempty(ch)
        out = [];
    else
        for i = ch
            if isa(i, 'hg2.HGGroup')
                out = getDescendantNonGroupChildren(i);
            else
                out = [i; getDescendantNonGroupChildren(i)];
            end
        end
    end
end

function [xDir, yDir, axScaleXPos, axScaleYPos, dummyExtent] = localContourLabelScaleParams(cax)
    if (strcmp(get(cax, 'XDir'), 'reverse'))
        xDir = -1;
    else
        xDir = 1;
    end
    if (strcmp(get(cax, 'YDir'), 'reverse'))
        yDir = -1;
    else
        yDir = 1;
    end
    
    % Compute scaling to make sure printed output looks OK. We have to go via
    % the figure's 'paperposition', rather than the absolute units of the
    % axes 'position' since those would be absolute only if we kept the 'units'
    % property in some absolute units (like 'points') rather than the default
    % 'normalized'. Also only do this when the parent is the figure to avoid
    % nested plots inside panels.
    
    parent = get(cax, 'Parent');
    axUnits = get(cax, 'Units');
    if strcmp(axUnits, 'normalized') && strcmp(get(parent, 'Type'), 'figure')
        axUnits = get(parent, 'Units');
        set(parent, 'Units', 'points');
        axPos = get(parent, 'Position');
        set(parent, 'Units', axUnits);
        axPos = axPos .* get(cax, 'Position');
    else
        axPos = hgconvertunits(ancestor(parent, 'figure'), get(cax, 'Position'), ...
            axUnits, 'points', parent);
    end
    
    % Find beginning of all lines
    
    xLim = get(cax, 'XLim');
    yLim = get(cax, 'YLim');
    
    axScaleXPos = axPos(3) / diff(xLim);  % To convert data coordinates to paper (we need to do this)
    axScaleYPos = axPos(4) / diff(yLim);  % to get the gaps for text the correct size)
    
    % Set up a dummy text object from which you can get text extent info
    % Temp Hack until Extents are ready
    dummyExtent = 5.65;
end

function [bValid, zLevel, lab, lp, xc, yc, trot] = localContourLabelRenderParams(cs, i, k, labels, dummyExtent, xDir, yDir, axScaleXPos, axScaleYPos, bManual, p, labelSpacing, textList)
    % Initialize some outputs
    lp = 0;
    xc = [];
    yc = [];
    trot = [];
    
    zLevel = cs(1, i);
    nPoints = cs(2, i);
    xp = cs(1, i + (1 : nPoints));
    yp = cs(2, i + (1 : nPoints));
    
    %RP - get rid of all blanks in label
    lab = labels(k, labels(k, :) ~= ' ');
    %RP - scale label length by string size instead of a fixed length
    len_lab = dummyExtent / 2 * length(lab);
    
    % RP28/10/97 - Contouring sometimes returns x vectors with
    % NaN in them - we want to handle this case!
    sx = xp * axScaleXPos;
    sy = yp * axScaleYPos;
    d = [0, sqrt(diff(sx) .^ 2 + diff(sy) .^ 2)];
    % Determine the location of the NaN separated sections
    section = cumsum(isnan(d));
    d(isnan(d)) = 0;
    d = cumsum(d);
    
    if bManual
        psn = min(max(max(d(p), d(2) + eps * d(2)), d(1) + len_lab), d(end) - len_lab);
        psn = max(0, min(psn, max(d)));
        bValid = true;
    else
        len_contour = max(0, d(nPoints) - 3 * len_lab);
        slop = (len_contour - floor(len_contour / labelSpacing) * labelSpacing);
        start = 1.5 * len_lab + max(len_lab, slop) * rands(1); % Randomize start
        psn = start : labelSpacing : d(nPoints) - 1.5 * len_lab;
        bValid = (isempty(textList) || any(abs(zLevel - textList) / max(eps + abs(textList)) < .00001));
    end
    
    if ~bValid
        return
    end
    
    lp = size(psn, 2);
    bValid = (lp > 0) && isfinite(zLevel);
    
    if ~bValid
        return
    end
    
    Ic = sum(d(ones(1, lp), :)' <  psn(ones(1, nPoints), :), 1);
    Il = sum(d(ones(1, lp), :)' <= psn(ones(1, nPoints), :) - len_lab, 1);
    Ir = sum(d(ones(1, lp), :)' <  psn(ones(1, nPoints), :) + len_lab, 1);
    
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
    
    bValid = ~isempty(Il);
    if ~bValid
        return
    end
    
    % Endpoints of text in data coordinates
    wl = (d(Il + 1) - psn + len_lab .* in) ./ (d(Il + 1) - d(Il));
    wr = (psn - len_lab .* in - d(Il)) ./ (d(Il + 1) - d(Il));
    xl = xp(Il) .* wl + xp(Il + 1) .* wr;
    yl = yp(Il) .* wl + yp(Il + 1) .* wr;
    
    wl = (d(Ir + 1) - psn - len_lab .* in) ./ (d(Ir + 1) - d(Ir));
    wr = (psn + len_lab .* in - d(Ir)) ./ (d(Ir + 1) - d(Ir));
    xr = xp(Ir) .* wl + xp(Ir + 1) .* wr;
    yr = yp(Ir) .* wl + yp(Ir + 1) .* wr;
    
    trot = atan2((yr - yl) * yDir * axScaleYPos, (xr - xl) * xDir * axScaleXPos) * 180 / pi;
    backang = abs(trot) > 90;
    trot(backang) = trot(backang) + 180;
    
    % Text location in data coordinates
    wl = (d(Ic + 1) - psn) ./ (d(Ic + 1) - d(Ic));
    wr = (psn - d(Ic)) ./ (d(Ic + 1) - d(Ic));
    xc = xp(Ic) .* wl + xp(Ic + 1) .* wr;
    yc = yp(Ic) .* wl + yp(Ic + 1) .* wr;
    
    % Shift label over a little if in a curvy area
    shiftfrac = .5;
    
    xc = xc * (1 - shiftfrac) + (xr + xl) / 2 * shiftfrac;
    yc = yc * (1 - shiftfrac) + (yr + yl) / 2 * shiftfrac;
end

function r = rands(sz)
    %RANDS Uniform random values without affecting the global stream
    dflt = RandStream.getDefaultStream();
    savedState = dflt.State;
    r = rand(sz);
    dflt.State = savedState;
end