function a = idnamchk(a,Name,Obj)
%IDNAMCHK Checks channel, state and parameter names

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $ $Date: 2008/10/02 18:51:33 $

% Checks specified I/O names
if isempty(a),
    a = a(:);   % make 0x1
    return
end

% Determine if first argument is an array or cell vector
% of single-line strings.
if ischar(a) && ndims(a)==2
    % A is a 2D array of padded strings
    a = cellstr(a);

elseif iscellstr(a) && ndims(a)==2 && min(size(a))==1
    % A is a cell vector of strings. Check that each entry
    % is a single-line string
    a = a(:);
    if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1),
        ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,Obj)
    end
else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,Obj)
end

% Make sure that nonempty I/O names are unique
if length(a)>1
    nonemptya = setdiff(a,{''});
    eI = strcmp(a,'');
    if  length(a)~=(sum(eI)+length(nonemptya))
        % Be forgiving for default state-names
        if strcmpi(Name,'statename') && all(strncmpi(a,'x',1))
            a = defnum([],'x',length(a));
        else
            ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,Obj)
        end
    end
end
