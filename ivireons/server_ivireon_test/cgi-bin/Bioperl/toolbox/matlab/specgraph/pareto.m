function [hh, ax] = pareto(varargin)
    %PARETO Pareto chart.
    %   PARETO(Y,NAMES) produces a Pareto chart where the values in the
    %   vector Y are drawn as bars in descending order.  Each bar will
    %   be labeled with the associated name in the string matrix or
    %   cell array NAMES.
    %
    %   PARETO(Y,X) labels each element of Y with the values from X.
    %   PARETO(Y) labels each element of Y with its index.
    %
    %   PARETO(AX,...) plots into AX as the main axes, instead of GCA.
    %
    %   [H,AX] = PARETO(...) returns a combination of patch and line object
    %   handles in H and the handles to the two axes created in AX.
    %
    %   See also HIST, BAR.
    
    %   Copyright 1984-2009 The MathWorks, Inc.
    %   $Revision: 1.23.4.9 $  $Date: 2009/12/11 20:36:03 $
    
    % Parse possible Axes input
    [cax, args, nargs] = axescheck(varargin{:});
    
    cax = newplot(cax);
    fig = ancestor(cax, 'figure');
    
    hold_state = ishold(cax);
    if nargs == 0
        error(id('NotEnoughInputs'), 'Not enough input arguments.');
    end
    if nargs == 1
        y = args{1};
        m = length(sprintf('%.0f', length(y)));
        names = reshape(sprintf(['%' int2str(m) '.0f'], 1:length(y)), m, length(y))';
    elseif nargs == 2
        y = args{1};
        names = args{2};
        if iscell(names)
            names = char(names);
        elseif ~ischar(names)
            names = num2str(names(:));
        end
    end
    
    if (min(size(y)) ~= 1)
        error(id('YMustBeVector'), 'Y must be a vector.');
    end
    y = y(:);
    [yy, ndx] = sort(y);
    yy = flipud(yy);
    ndx = flipud(ndx);
    
    h = bar(cax, 1:length(y), yy);
    
    h = [h; line(1:length(y), cumsum(yy), 'Parent', cax)];
    ysum = sum(yy);
    
    if ysum == 0
        ysum = eps;
    end
    k = min(find(cumsum(yy) / ysum > .95, 1), 10);
    
    if isempty(k)
        k = min(length(y), 10);
    end
    
    xLim = [.5 k+.5];
    yLim = [0 ysum];
    set(cax, 'XLim', xLim);
    set(cax, 'XTick', 1:k, 'XTickLabel', mat2cell(names(ndx(1:k), :), ones(1, k)), 'YLim', yLim);
    
    raxis = axes('Position', get(cax, 'Position'), 'Color', 'none', ...
        'XGrid', 'off', 'YGrid', 'off', 'YAxisLocation', 'right', ...
        'XLim', xLim, 'YLim', yLim, ...
        'HandleVisibility', get(cax, 'HandleVisibility'), ...
        'Parent', fig);
    yticks = get(cax, 'YTick');
    if max(yticks) < .9 * ysum
        yticks = unique([yticks, ysum]);
    end
    set(cax, 'YTick', yticks)
    s = cell(1, length(yticks));
    for n = 1:length(yticks)
        s{n} = [int2str(round(yticks(n) / ysum * 100)) '%'];
    end
    set(raxis, 'YTick', yticks, 'YTickLabel', s, 'XTick', []);
    set(fig, 'CurrentAxes', cax);
    if ~hold_state
        hold(cax, 'off');
        set(fig, 'NextPlot', 'Replace');
    end
    
    if nargout > 0
        hh = h;
        ax = [cax raxis];
    end
end

function str=id(str)
    str = ['MATLAB:pareto:' str];
end
