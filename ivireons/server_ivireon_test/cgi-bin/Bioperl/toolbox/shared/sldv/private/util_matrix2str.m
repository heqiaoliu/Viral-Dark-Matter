function str = util_matrix2str(in)
    mxStr = util_num2str(in);
    [line, col] = size(mxStr); %#ok<NASGU>
    if line > 1
        str = mxStr(1,:);
        for i=2:line
            str = [ str '; ' mxStr(i,:) ]; %#ok<AGROW>
        end
    else
        str = mxStr;
    end
    str = regexprep(str,'\s+',' ');
    str = [ '[' str ']' ];
end
