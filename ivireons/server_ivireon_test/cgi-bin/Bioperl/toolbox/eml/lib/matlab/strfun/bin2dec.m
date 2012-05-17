function x = bin2dec(s)
%Embedded MATLAB Library Function

%   Limitations:  Doesn't accept cell input.

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ischar(s), ...
    'MATLAB:bin2dec:InvalidInputClass', ...
    'Input must be a string.');
eml_lib_assert(ndims(s) == 2, ...
    'EmbeddedMATLAB:bin2dec:inputMustBe2D', ...
    'Input must be 2D.');
if isempty(s)
    x = [];
    return
end
eml_prefer_const(s);
nbits = eml_const(floor(-log2(eps)));
% For error reporting only.
eml.extrinsic('int2str');
eml_lib_assert(size(s,2) <= nbits, ...
    'MATLAB:bin2dec:InputOutOfRange', ...
    ['Binary string must be ' eml_const(int2str(nbits)) ' bits or less.']);
eml_lib_assert(isa_bin_string(s), ...
    'MATLAB:bin2dec:IllegalBinaryString', ...
    'Binary string may consist only of characters 0 and 1');
if eml_is_const(s)
    % Force constant output -- the usual case.
    x = eml_const(local_bin2dec(s));
else
    x = local_bin2dec(s);
end

%--------------------------------------------------------------------------

function x = local_bin2dec(s)
% Calculate double precision decimal equivalents for binary strings.
x = zeros(size(s,1),1);
for k = 1:size(s,1)
    p2 = 1;
    for j = size(s,2):-1:1
        if s(k,j) ~= ' '
            if s(k,j) == '1'
                x(k) = x(k) + p2;
            end
            p2 = p2 + p2;
        end
    end
end

%--------------------------------------------------------------------------

function p = isa_bin_string(s)
% Returns true iff s is a string with entries in {0, ' ', '0', '1'}. 
for k = 1:numel(s)
    if s(k) ~= '0' && s(k) ~= 0 && s(k) ~= ' ' && s(k) ~= '1'
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------
