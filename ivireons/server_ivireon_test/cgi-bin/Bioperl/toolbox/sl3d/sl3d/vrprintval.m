function vrprintval(name, value)
%VRPRINTVAL Prints a name-value pair using Simulink 3D Animation formatting.
%   VRPRINTVAL(NAME, VALUE) prints a name-value pair
%   using the default format of Simulink 3D Animation.
%
%   VRPRINTVAL(S) prints the contents of a structure S using
%   the default format of Simulink 3D Animation.
%
%   All VR functions that print name-value pairs use this function.
%   This ensures that all outputs from Simulink 3D Animation functions are
%   formatted in the same way.
%
%   This method is used internally.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/03/01 05:30:19 $ $Author: batserve $


% process structures
if isa(name, 'struct')
    s = name;
    
    % argument is an empty array of structs: nothing to print
    if isempty(s)
      warning('VR:emptyoutput', 'Nothing to print.');
      return
    end
    
    compact = isequal(get(0, 'FormatSpacing'), 'compact');
    flds = fields(s);
    if (~compact)
      disp(' ');
    end
    for i=1:length(flds)
        vrprintval(flds{i}, s.(flds{i}));
    end
    if (~compact)
      disp(' ');
    end
    return
end

% process character arrays
if isa(value, 'char')
    if isempty(value)
        result = '''''';
    elseif ndims(value) == 2
        sz = size(value);
        if (sz(1) == 1) && (sz(2) < 64)
            % do not print line feeds
            value = regexprep(value, '\n', ' ');
            result = ['''' value ''''];
        else
            result = sprintf('char array: %s%d', ...
                sprintf('%d-by-', sz(1:end-1)), ...
                sz(end));
        end
    end

% process numeric and logical arrays
elseif isnumeric(value) || islogical(value)
    if isempty(value)
        result = '[]';
    elseif length(value) == 1
        result = sprintf('%g', value);
    elseif ndims(value) >= 2
        sz = size(value);
        if (ndims(value)<3) && (sz(1) < 32) && (sz(2) < 32) && (prod(sz) < 32)
            result = '[';
            for i=1:sz(1)
                result = [result sprintf('%g ', value(i, 1:sz(2)-1))];     %#ok<AGROW> string concatenation
                result = [result sprintf('%g', value(i, sz(2)))];     %#ok<AGROW> string concatenation
                if (i<sz(1))
                    result = [result '; '];     %#ok<AGROW> string concatenation
                end
            end
            result = [result ']'];
        else
            result = sprintf('%s array: %s%d', ...
                class(value), ...
                sprintf('%d-by-', sz(1:end-1)), ...
                sz(end));
        end
    end
    
% process cell arrays
elseif isa(value, 'cell')
    sz = size(value);
    result = sprintf('cell array: %s%d', ...
        sprintf('%d-by-', sz(1:end-1)), ...
        sz(end));
    
% process other values
else
    sz = size(value);
    result = sprintf('%s object: %s%d', ...
        class(value), ...
        sprintf('%d-by-', sz(1:end-1)), ...
        sz(end));
end

fprintf('\t%s = %s\n', name, result);
