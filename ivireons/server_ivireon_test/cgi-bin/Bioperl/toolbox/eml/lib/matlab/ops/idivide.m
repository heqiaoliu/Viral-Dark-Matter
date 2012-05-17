function c = idivide(a,b,opt)
%Embedded MATLAB Library Function

%   Limitations:
%     1. If supplied, the OPT string must be in lower case.
%     2. For efficient generated code, MATLAB divide-by-zero rules
%        are supported only for the 'round' option.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2,'Not enough input arguments.');

if eml_ambiguous_types
    c = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b);
    c(:) = 0;
    return
end

% Validate input.
idivide_check(a,b);

if nargin < 3 || strcmp(opt,'fix')
    c = idivide_fix(a,b);
elseif strcmp(opt,'floor')
    c = idivide_floor(a,b);
elseif strcmp(opt,'ceil')
    c = idivide_ceil(a,b);
elseif strcmp(opt,'round')
    c = a ./ b;
else
    % Change the strcmp calls to strcmpi when the latter can be
    % constant-folded and then update this error message.
    eml_assert(false, ... % 'MATLAB:idivide:InvalidRoundingOption', ...
        'Unrecognized rounding option. Use lower case ''fix'', ''floor'', ''round'', or ''ceil''.'); 
end

%--------------------------------------------------------------------------

function idivide_check(a,b)
% Validate input.
eml_transient;
eml_assert(isinteger(a) || isinteger(b), ... 
    'At least one argument must belong to an integer class.');
eml_assert(isreal(a) && isreal(b), ... 
    'Complex integer arithmetic is not supported.');
eml_assert(isa(a,class(b)) || ...
    (isinteger(a) && (isscalar(b) && isa(b,'double'))) || ...
    (isinteger(b) && (isscalar(a) && isa(a,'double'))), ...
    'Integers can only be combined with integers of the same class, or scalar doubles.');

%--------------------------------------------------------------------------

function c = idivide_fix(a,b)
% Integer division with rounding towards zero.
if isa(a,'float')
    c = cast( fix( a ./ double(b) ) , class(b) );
elseif isa(b,'float')
    c = cast( fix( double(a) ./ b ) , class(a) );
else
    c = eml_idivide(a,b,'to zero');
end

%--------------------------------------------------------------------------

function c = idivide_floor(a,b)
% Integer division with rounding towards negative infinity.
if isa(a,'float')
    c = cast( floor( a ./ double(b) ) , class(b) );
elseif isa(b,'float')
    c = cast( floor( double(a) ./ b ) , class(a) );
else
    c = eml_idivide(a,b,'floor');
end

%--------------------------------------------------------------------------

function c = idivide_ceil(a,b)
% Integer division with rounding towards infinity.
if isa(a,'float')
    c = cast( ceil( a ./ double(b) ) , class(b) );
elseif isa(b,'float')
    c = cast( ceil( double(a) ./ b ) , class(a) );
else
    c = eml_idivide(a,b,'ceil');
end

%--------------------------------------------------------------------------

function c = eml_idivide(a,b,opt)
% Do scalar expansion and call eml_rdivide.
eml_must_inline;
% For efficiency of the generated code, we choose not to support division
% by zero.
for k = 1:eml_numel(b)
    if b(k) == 0
        eml_error('EmbeddedMATLAB:idivide:divideByZero','Divide by zero.');
    end
end
c = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b);
for k = 1:eml_numel(c)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    % MATLAB divide-by-zero logic:
    % if bk == 0 
    %     if ak < 0
    %         c(k) = intmin(class(c));
    %     elseif ak == 0
    %         c(k) = 0;
    %     else
    %         c(k) = intmax(class(c));
    %     end
    %     continue  
    % end
    c(k) = eml_rdivide(ak,bk,class(c),opt);
end

%--------------------------------------------------------------------------
