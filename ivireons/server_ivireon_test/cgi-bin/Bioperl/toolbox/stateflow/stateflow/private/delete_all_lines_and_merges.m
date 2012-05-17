function delete_all_lines_and_merges(blockH)
    % This is a heavy duty hammer which deletes all lines emanating from a
    % given block. If this block is connected to other blocks which have
    % lines coming out of them, those are deleted as well.

%   Copyright 2008 The MathWorks, Inc.
    
    % For all intents and purposes, it would have been fine to replace this
    % with a simpler script like:
    %
    %   parent = get_param(blockH, 'Parent');
    %   lines = find_system(parent, 'FindAll', 'on', 'Type', 'line');
    %   delete_line(lines);
    %
    % However, that doesn't seem to work in the twilight zone where a
    % library link is broken and we are asked to create a new instance.
    % Hence the need for all these clever tricks.
    
    lineHandles = get_param(blockH, 'LineHandles');
    fields = fieldnames(lineHandles);
    
    % All lines emanating from this block.
    lines =  [];
    for i=1:length(fields)
        lines = [lines, lineHandles.(fields{i})]; %#ok<AGROW>
    end
    % Only consider valid lines.
    lines = lines(ishandle(lines));
    
    % All blocks connected to this block.
    blocks = [];
    for i=1:length(lines)
        blocks = [blocks; get_param(lines(i), 'SrcBlockHandle')]; %#ok<AGROW>
        blocks = [blocks; get_param(lines(i), 'DstBlockHandle')]; %#ok<AGROW>
    end
    
    % delete all the lines to prevent infinite recursion.
    delete_line(lines);
    
    % recurse to all blocks connected to this block.
    for i=1:length(blocks)
        % We need ishandle because the merge might have disappeared in the
        % recursive call.
        if ishandle(blocks(i))
            delete_all_lines_and_merges(blocks(i));
        end
        
        if ishandle(blocks(i)) && strcmpi(get_param(blocks(i), 'BlockType'), 'Merge')
            delete_block(blocks(i));
        end
    end
end
