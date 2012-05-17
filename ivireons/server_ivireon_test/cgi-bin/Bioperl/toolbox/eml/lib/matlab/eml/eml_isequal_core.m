function p = eml_isequal_core(equalnans,varargin)
%Embedded MATLAB Private Function

%   For ISEQUAL, use eml_isequal_core(false,...).
%   For ISEQUALWITHEQUALNANS, use eml_isequal_core(true,...).

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_allow_enum_inputs;
eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(isscalar(equalnans) && islogical(equalnans), ...
    'First input must be scalar ''logical''.');
eml_prefer_const(equalnans);
if equalnans
    fcn = 'isequalwithequalnans';
else
    fcn = 'isequal';
end
for k = eml.unroll(1:nargin-1)
    eml_assert(isnumeric(varargin{k}) || ischar(varargin{k}) || ...
        islogical(varargin{k}) || isstruct(varargin{k}), ...
        ['Function ' fcn ' is not defined for values of class ''' ...
        class(varargin{k}) '''.']);
end
p = false;
for k = eml.unroll(2:nargin-1)
    if ~binary_isequal(equalnans,varargin{1},varargin{k})
        return
    end
end
p = true;

%--------------------------------------------------------------------------

function p = same_size(x1,x2)
eml_allow_enum_inputs;
p = false;
if ndims(x1) ~= ndims(x2)
    return
end
for k = 1:ndims(x1)
    if size(x1,k) ~= size(x2,k)
        return
    end
end
p = true;
    
%--------------------------------------------------------------------------

function p = binary_isequal(equalnans,x1,x2)
eml_allow_enum_inputs;
eml_must_inline;
p = same_size(x1,x2) && ...
    isstruct(x1) == isstruct(x2);
if p
    if ~isempty(x1) && ~isempty(x2)
        for k = 1:eml_numel(x1)
            if ~isequal_scalar(equalnans,x1(k),x2(k));
                p = false;
                return
            end
        end
    end
end

%--------------------------------------------------------------------------

function p = isequal_scalar(equalnans,x1,x2)
% Compare two 1x1 objects.
eml_allow_enum_inputs;
eml_must_inline;
if isstruct(x1)
    p = eml_ambiguous_types || isequal_struct(equalnans,x1,x2);
elseif eml.isenum(x1) || eml.isenum(x2)
    p = int32(x1) == int32(x2);
elseif equalnans
    if isreal(x1) && isreal(x2)
        p = x1 == x2 || (isnan(x1) && isnan(x2));
    else
        p = (real(x1) == real(x2) || (isnan(real(x1)) && isnan(real(x2)))) && ...
            (imag(x1) == imag(x2) || (isnan(imag(x1)) && isnan(imag(x2))));
    end
else
    p = x1 == x2;
end

%--------------------------------------------------------------------------

function p = isequal_struct(equalnans,x1,x2)
% Compare two structs.
eml_must_inline;
p = same_struct_fieldnames(x1,x2) && ...
    isequal_struct_field(equalnans,x1,x2,eml_numfields(x1));

%--------------------------------------------------------------------------

function p = same_struct_fieldnames(x1,x2)
% Determine whether structs X1 and X2 have exactly the same field names.
eml_transient;
p = false;
n = eml_numfields(x1);
if eml_numfields(x2) == n
    % This is O(n^2) in the worst case, but if the field names of both
    % structs are in the same order, it is O(n).
    for k = eml.unroll(0:n-1)
        if ~has_fieldname(x1,x2,k)
            return
        end
    end
    p = true;
end

%--------------------------------------------------------------------------

function p = has_fieldname(x1,x2,k)
% Determine whether EML_GETFIELDNAME(X1,K) is also a field name of X2.
% Structs X1 and X2 must have the same number of fields.
eml_transient;
p = true;
s = eml_getfieldname(x1,k);
if ~strcmp(s,eml_getfieldname(x2,k))
    for j = eml.unroll(0:eml_numfields(x1)-1)
        if j ~= k && strcmp(s,eml_getfieldname(x2,j))
            return
        end
    end
    p = false;
end

%--------------------------------------------------------------------------

function p = isequal_struct_field(equalnans,x1,x2,k)
% Recursive comparison of struct fields, where x1 and x2 have exactly the
% same set of field names.
eml_must_inline;
if k == 0
    p = true;
else
    k = k - 1; % eml_getfieldname uses zero-based indexing, so decrement k.
    s1 = eml_getfieldname(x1,k);
    p = binary_isequal(equalnans,eml_getfield(x1,s1),eml_getfield(x2,s1)) ...
        && isequal_struct_field(equalnans,x1,x2,k);
end

%--------------------------------------------------------------------------
