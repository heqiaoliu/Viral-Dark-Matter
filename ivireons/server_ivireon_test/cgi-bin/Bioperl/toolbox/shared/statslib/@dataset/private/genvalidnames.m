function [names,wereModified] = genvalidnames(names,allowMods)
%GENVALIDNAMES Construct valid identifiers from a list of names.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/07/06 20:47:35 $

wereModified = false;
if nargin < 2, allowMods = true; end

% Loop over all names and make them valid identifiers.  This is the same code
% that genvarnames uses, without the uniqueness checking.
for k = 1:numel(names)
    name = names{k};

    if ~isvarname(name)
        if allowMods
            wereModified = true;
        else
            error('stats:dataset:genvalidnames:InvalidVariableName', ...
                  '''%s'' is not a valid variable name.',name);
        end

        % Insert x if the first column is non-letter.
        name = regexprep(name,'^\s*+([^A-Za-z])','x$1', 'once');

        % Replace whitespace with camel casing.
        [StartSpaces, afterSpace] = regexp(name,'\S\s+\S');
        name(afterSpace) = upper(name(afterSpace));
        name = regexprep(name,'\s*','');
        if (isempty(name))
            name = 'x';
        end
        % Replace non-word character with its HEXADECIMAL equivalent
        illegalChars = unique(name(regexp(name,'[^A-Za-z_0-9]')));
        for illegalChar=illegalChars
            if illegalChar <= intmax('uint8')
                width = 2;
            else
                width = 4;
            end
            replace = ['0x' dec2hex(illegalChar,width)];
            name = strrep(name, illegalChar, replace);
        end

        % Prepend keyword with 'x' and camel case.
        if iskeyword(name)
            name = ['x' upper(name(1)) name(2:end)];
        end

        % Truncate name to NAMLENGTHMAX
        name = name(1:min(length(name),namelengthmax));

        names{k} = name;
    end
end

if wereModified
    warning('stats:dataset:genvalidnames:ModifiedVarnames', ...
            'Variable names were modified to make them valid MATLAB identifiers.');
end
