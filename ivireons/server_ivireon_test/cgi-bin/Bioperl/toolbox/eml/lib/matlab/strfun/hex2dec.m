function x = hex2dec(s)
%Embedded MATLAB Library Function

%   Limitations:  Doesn't accept cell input.

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ischar(s), ...
    'MATLAB:hex2dec:InvalidInputClass', ...
    'Input must be a string.');
eml_lib_assert(ndims(s) <= 2, ...
    'EmbeddedMATLAB:hex2dec:inputMustBe2D', ...
    'Input must be 2D.');
if isempty(s)
    x = [];
    return
end
eml_prefer_const(s);
eml_lib_assert(isa_hex_string(s), ...
    'MATLAB:hex2dec:IllegalHexadecimal', ...
    'Input string found with characters other than 0-9, a-f, or A-F.');
if eml_is_const(s)
    % Force constant output -- the usual case.
    x = eml_const(local_hex2dec(s));
else
    x = local_hex2dec(s);
end

%--------------------------------------------------------------------------

function x = local_hex2dec(s)
% Calculate double precision decimal equivalents for binary strings.
x = zeros(size(s,1),1);
for k = 1:size(s,1)
    p16 = 1;
    for j = size(s,2):-1:1
        if s(k,j) ~= ' '
            skj = double(s(k,j));
            if skj ~= 0 && skj ~= '0'
                if skj <= '9'
                    skj = skj - '0'; % '0':'9' --> 0:9
                elseif skj > 'F'
                    skj = skj - 'a' + 10; % 'a':'f' --> 10:15
                else
                    skj = skj - 'A' + 10; % 'A':'F' --> 10:15
                end
                x(k) = x(k) + skj*p16;
            end
            p16 = 16*p16;
        end
    end
end

%--------------------------------------------------------------------------

function p = isa_hex_string(s)
% Returns true iff s is a string with entries in {0, ' ', '0', '1'}.
for k = 1:numel(s)
    if ~(s(k) == ' ' || s(k) == 0 || ...
            (s(k) >= 'A' && s(k) <= 'F') || ...
            (s(k) >= 'a' || s(k) <= 'f'))
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------
