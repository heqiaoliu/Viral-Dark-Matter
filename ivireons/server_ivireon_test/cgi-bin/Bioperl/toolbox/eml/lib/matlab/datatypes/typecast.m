function y = typecast(x,datatype)
%Embedded MATLAB Library Function

%   Limitations:
%   1. The second argument must be supplied in all lower case.
%   2. Inheritance of the class of the first argument X to TYPECAST in an 
%   Embedded MATLAB Function block is only supported when class(x) is 
%   'double'.  For non-double inputs, the input port data types must be
%   specified, not inherited. 

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(x,'numeric') && isreal(x), ...
    'The first input argument must be a full, non-complex numeric value.');
eml_assert(eml_is_const(isvector(x)), ...
    ['First argument must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(x) || ...
    (eml_is_const(size(x)) && isempty(x) && eml_ndims(x) == 2), ...
    ... % 'MATLAB:typecastc:firstArgMustBeVector', ...
    'The first input argument must be a vector.');
if eml.isenum(x)
    bpex = eml_const(bytes_per_element('int32'));
else
    bpex = eml_const(bytes_per_element(class(x)));
end
bpey = eml_const(bytes_per_element(datatype));
if eml_is_const(size(x)) && isempty(x)
    y = cast(zeros(size(x)),datatype);
    return
end
nbytes = eml_times(bpex,eml_numel(x));
outlen = eml_rdivide(nbytes,bpey);
eml_lib_assert(eml_scalar_floor(outlen) == outlen, ...
    'MATLAB:typecastc:notEnoughInputElements', ...
    'Too few input values to make output type.');
if size(x,1) > 1
    outsize = [outlen,1];
else
    outsize = [1,outlen];
end
y = eml.nullcopy(cast(zeros(outsize),datatype));
if eml_ambiguous_types
    y(:) = 0;
    return
end
szt = cast(nbytes,eml_unsigned_class(eml_index_class));
ignr = eml.opaque('void*');
ignr = eml.ceval('memcpy',eml.wref(y(1)),eml.rref(x(1)),szt); %#ok<NASGU>

%--------------------------------------------------------------------------

function b = bytes_per_element(cls)
switch cls
    case {'double','int64','uint64'}
        b = 8;
    case {'single','int32','uint32'}    
        b = 4;
    case {'int16','uint16'}
        b = 2;
    case {'int8','uint8'}
        b = 1;
    otherwise
        eml_assert(false,'Unsupported class.');
end

%--------------------------------------------------------------------------
