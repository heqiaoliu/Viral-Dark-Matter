function chart_retile(chart)

% Copyright 2005-2008 The MathWorks, Inc.

    ax = sf('get', chart.id, '.hg.axes');

    % We (Jay T, Steve C, and Tom W) decided that the foreground lines are helpful in all cases.
    % So, hardcode this to true
    usingLines = true;
    
    % How big do our patches need to be?
    patchsize = get_patchsize(chart);
    patchwidth = patchsize(1);
    patchheight = patchsize(2);

    % How many patches and lines will we need?
    xlim = get(ax, 'XLim');
    ylim = get(ax, 'YLim');
    width = abs(xlim(1) - xlim(2));
    height = abs(ylim(1) - ylim(2));
    if (should_show_patches(chart) && patchwidth ~= 0 && patchheight ~= 0)
        xpatches = ceil(width / patchwidth);
        ypatches = ceil(height / patchheight);
        xlines = xpatches - 1;
        ylines = ypatches - 1;
        numPatchesNeeded = floor((xpatches * ypatches)/2);
        numLinesNeeded = xlines + ylines;

        % Saturate on number of lines/patches to avoid performance issues
        if (numPatchesNeeded > 1000) 
            xpatches = 0;
            ypatches = 0;
            numPatchesNeeded = 0;
        end

        if (~usingLines || numLinesNeeded > 1000) 
            xlines = 0;
            ylines = 0;
            numLinesNeeded = 0;
        end
    else
        xpatches = 0;
        ypatches = 0;
        numPatchesNeeded = 0;
        xlines = 0;
        ylines = 0;
        numLinesNeeded = 0;
    end

    % How many patches/lines do we have?
    availablePatches = findobj(ax, 'Type', 'Patch', 'Tag', 'print_patch');
    numPriorPatches = length(availablePatches);
    availableLines = findobj(ax, 'Type', 'Line', 'Tag', 'print_line');
    numPriorLines = length(availableLines);

    
    % Ensure we have at least as many patches/lines as we need
    if (numPriorPatches < numPatchesNeeded)
        availablePatches = [availablePatches; ...
                            make_new_patches(numPatchesNeeded - numPriorPatches, patchsize, ax, get_patch_color(chart))];
    end
    if (numPriorLines < numLinesNeeded)
        availableLines = [availableLines; ...
                          make_new_lines(numLinesNeeded - numPriorLines, ax, get_patch_color(chart))];
    end
    
    % Now, place the patches correctly
    usedPatches = [];
    i = 1;
    for x=1:xpatches
        for y=1:ypatches
            xd = patchwidth * (x-1);
            yd = patchheight * (y-1);
            if (mod(x+y, 2))            
                color = get_patch_color(chart);
                set(availablePatches(i), ...
                    'HitTest', 'off', ...
                    'FaceColor', color, ...
                    'EdgeColor', color, ...
                    'XData', [xd xd+patchwidth xd+patchwidth xd], ...
                    'YData', [yd yd yd+patchheight yd+patchheight]);
                usedPatches = [usedPatches; availablePatches(i)];
                i = i + 1;
            end
        end
    end
    usedLines = [];
    j = 1;
    for x=1:xlines
        xd = patchwidth * x;
        set(availableLines(j), ...
            'HitTest', 'off', ...
            'Color',  get_patch_color(chart), ...
            'XData', [xd xd], ...
            'YData', [0 ylim(2)]);
        usedLines = [usedLines; availableLines(j)];
        j = j + 1;
    end    
    for y=1:ylines
        yd = patchheight * y;
        set(availableLines(j), ...
            'HitTest', 'off', ...
            'Color',  get_patch_color(chart), ...
            'XData', [0 xlim(2)], ...
            'YData', [yd yd]);
        usedLines = [usedLines; availableLines(j)];
        j = j + 1;
    end

    % Shut off all the unused patches/lines, but keep them around for future
    unusedPatches = availablePatches(i:end);
    set(unusedPatches, 'Visible', 'off');
    unusedLines = availableLines(j:end);
    set(unusedLines, 'Visible', 'off');


    % Move the patches to the background 
    allKids = get(ax, 'Children');
    [sortedKids, ix] = setdiff(allKids, usedPatches); 
    otherKids = allKids(sort(ix));
    newKids = [otherKids; usedPatches];
    set(ax, 'Children', newKids);

    % Move the lines to the foreground
    allKids = get(ax, 'Children');
    [sortedKids, ix] = setdiff(allKids, usedLines); 
    otherKids = allKids(sort(ix));
    newKids = [usedLines; otherKids];
    set(ax, 'Children', newKids);
    

    % Finally, "turn on" the patches/lines
    set(usedPatches, 'Visible', 'on');
    set(usedLines, 'Visible', 'on');
end


function np = make_new_patches(numToMake, size, ax, color)
    np = [];
    for i=1:numToMake
        p = patch('Parent', ax, ...
                  'Tag', 'print_patch', ...
                  'XData', [0 size(1) size(1) 0], ...
                  'YData', [0 0 size(2) size(2)], ...
                  'FaceColor', color, ...
                  'EdgeColor', color, ...
                  'Visible', 'off');
        np = [np; p];
    end
end

function nl = make_new_lines(numToMake, ax, color)
    nl = [];
    for i=1:numToMake
        l = line('Parent', ax, ...
                 'Tag', 'print_line', ...
                 'LineWidth', 1, ...
                 'Visible', 'off');
        nl = [nl; l];
    end
end


function color = get_patch_color(chart)
    cc = chart.ChartColor;
    if (sum(cc) == 0)
        color = [.15 .15 .15];
    elseif (sum(cc) < 0.77) 
        color = 1.3 * cc;
    else
        color = cc * 0.95;
    end
end

function ps = get_patchsize(chart)

    ss = chart.up;

    psize = ss.PaperSize;
    if (isequal(ss.PaperUnits, 'normalized'))
        % normalized signifies a percentage of page size
        psize = paper_size(ss.PaperType);
    end
    size = psize;
    
    % remove margins from the page
    marginRect = ss.TiledPaperMargins;
    margin = [marginRect(1)+marginRect(3), marginRect(2)+marginRect(4)];
    if (isequal(ss.PaperUnits, 'normalized'))
        % normalized signifies a percentage of page size
        size(1) = size(1) - size(1)*margin(1);
        size(2) = size(2) - size(2)*margin(2);
    else
        % otherwise, it's a difference
        size = size - margin;
    end
    
    if (any(size<=0))
        size = psize;
    end
    
    
    % Convert whatever units we have to points, the units of the SF editor
    switch (ss.PaperUnits)
      case 'centimeters'
        % Axes units are in points.  There are 2.54 cm per inch,
        % and 72 points per inch
        size = size * 72 / 2.54;
      case 'inches'
        % 72 points per inch
        size = size * 72;
      case 'normalized'
        % paper_size returns inches, so convert as if inches
        size = size * 72;
      % nothing to do for points
    end
    
    size = size * ss.TiledPageScale;
    
    % Note there is no need to take into account paper orientation, 
    % as the UDD property for papersize does that for us
    
    % One last scale to take into account hardcoded scale value
    % in Simulink/Stateflow printing
    ps = size * (96 / 72);
end    
    
    

function show = should_show_patches(chart)
    ss = chart.up;
    show = (isequal(ss.ShowPageBoundaries, 'on') && isequal(ss.PaperPositionMode, 'tiled'));
end
