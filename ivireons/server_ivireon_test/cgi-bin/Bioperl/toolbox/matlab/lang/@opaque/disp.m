function disp(opaque_array)
%DISP DISP for a Java object.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.22.4.4 $  $Date: 2009/08/14 04:01:25 $

if ~isjava(opaque_array),
    builtin('disp', opaque_array);
    return;
end
try
    cls = class(opaque_array);
    if  isempty(strfind(cls, '[][][]')) && ...
                strncmp('java.lang.String[]',cls,length('java.lang.String[]'));
        disp(' ');
    end

    if cls(end) ~= ']'
        desc = char(toString(opaque_array));
    else
        disp([cls ':']);
        desc = cell(opaque_array);
        isColumn = size(desc, 2)==1;
        desc = evalc('disp(desc)');
        if (~isempty(strfind(desc, '{[]}')))
            desc = '    []';
        else
            if isempty(desc),
                desc = ['    [0 element array]' 10 10];
            else
                desc = regexprep(desc, '^(\s*)\{(.*)\}(\s*)$', '$1[$2]$3');
                if isColumn
                    desc = strrep(desc, '[1x1 ', '[');
                else
                    desc = strrep(desc, '[1x1 ', '    [');
                end
            end
        end
    end

    disp(desc);
    if strcmp(get(0, 'FormatSpacing'), 'loose')
        disp(' ');
    end
catch exc %#ok<NASGU>
  builtin('disp', opaque_array);
end
