function string = tag2string(hObj, tag)
%TAG2STRING Map a tag to a string

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/12/14 15:19:23 $

tags = get(hObj, 'Identifiers');
strs = get(hObj, 'String');

string = '';

for i = 1:length(tags)
    if ischar(tags{i}),
        if strcmpi(tag, tags{i}),
            string = strs{i};
            return;
        end
    else
        indx = find(strcmpi(tag, tags{i}));
        switch length(indx)
            case 0
                % NO OP
            case 1
                string = strs{i}{indx-difference(hObj,i)};
            case 2
                if indx(1) == 1,
                    string = strs{i}{indx(2-difference(hObj, i))};
                else
                    error(generatemsgid('GUIErr'),'Cannot determine string from tag.');
                end                    
            otherwise
                error(generatemsgid('GUIErr'),'Cannot determine string from tag.');
        end
    end
end

% [EOF]
