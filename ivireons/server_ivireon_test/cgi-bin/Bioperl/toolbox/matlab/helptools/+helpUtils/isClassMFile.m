function [b, className] = isClassMFile(fullPath)
    whichComment = regexp(evalc(helpUtils.makeDualCommand('which', fullPath)), '%.*', 'match', 'once');
    classSplit = regexp(whichComment, '%.*?(?<name>\w*)\s*constructor\s*($|,)', 'names', 'once');
    b = ~isempty(classSplit);
    if b
        className = classSplit.name;
    else
        className = '';
    end
