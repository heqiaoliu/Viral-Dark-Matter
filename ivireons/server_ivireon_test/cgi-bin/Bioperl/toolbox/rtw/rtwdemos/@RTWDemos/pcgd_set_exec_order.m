function pcgd_set_exec_order(modNum,exeOrdNum)
    % 0.) Get the data
    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
    
    % 1.) Get the model
    schedBlock = [pcgDemoData.Models{modNum},'/Execution_Order_Control'];

    % make sure the model is open
    [pcgDemoData] = RTWDemos.pcgd_modelIsOpen(pcgDemoData,modNum);    

    % 2.) Get the possible selections for the block
    sel = get_param(schedBlock,'MemberBlocks');
    sel = stringToCell(sel,',');

    % .) Set the block selection
    set_param(schedBlock,'BlockChoice',sel{exeOrdNum});
    
    save_system(pcgDemoData.Models{modNum});
 
end

function [c] = stringToCell(s,d)
    % Convert a delimited string to a cell array
    % E.g., input is    "blah 1" "blah 2", delimiter is ",  
    %           output:    {'blah 1', 'blah 2'}

    % Copyright 2001-2007 The MathWorks, Inc.
    % $Revision: 1.1.6.1 $ $Date: 2007/06/18 23:05:38 $

    c = {};
    while containsValidString(s),
        [s1 s] = strtok(s, d);
        if containsValidString(s1)
            c = {c{:} s1};
        end
    end
end
% ---------------------------------------
function ok = containsValidString(s)
    % Decide whether there is still valid data in s.
    % I.e., if s only contains separators, quotes, spaces,
    % newlines, etc (in any combination), then it
    % is not valid.
    % This is to be decided in the context of 
    % valid filenames, valid code symbols, etc.

    goodChars = [ ...
        'abcdefghijklmnopqrstuvwxyz' ...
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ...
        '1234567890' ...
        '_~-.!#$%'];
    % !"#$%&'()*+,-./0123456789:;<=>?@
    % [\]^_`
    s2 = strtok(s, goodChars);
    % If s2 does not contain any of these characters,
    % s and s2 will be equal.
    ok = ~isequal(s2, s);
end
