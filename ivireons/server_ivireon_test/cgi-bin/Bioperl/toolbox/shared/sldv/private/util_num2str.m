function str = util_num2str(num)
    if isa(num, 'embedded.fi')
        str = local_num2str(num.double);
    elseif isobject(num)
        str = local_enum2str(num);
    else
        str = local_num2str(num);
    end
end

function str = local_num2str(x)
    str = num2str(x);
    if islogical(x)
        [rwCnt,colCnt] = size(x); %#ok<NASGU>
        if rwCnt>1
            for rw=1:rwCnt
                str(rw,:) = strrep(str(rw,:),'0','F');
                str(rw,:) = strrep(str(rw,:),'1','T');
            end
        else
            str = strrep(str,'0','F');
            str = strrep(str,'1','T');
        end
    end
end

function str = local_enum2str(x)
    [val, names] = enumeration(x);
    c = val == x;
    % We want the first name corresponding to the value encountered.
    allMatches = names(c);
    if(isempty(allMatches))
        error('SLDV:util_num2str:BadValue', 'Empty string corresponding to enumerated value');
    else
        str = allMatches{1};
    end
end