function [C,r] = linsolve(A,B,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. Only UT and LT cases are optimized.  All other options are
%   equivalent to using MLDIVIDE.
%   2. The option structure must be a constant.
%   3. Arrays of input structures are not supported, only a scalar
%      structure input.

%   Copyright 2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(nargin <= 3, ...
    'Embedded MATLAB only supports one option structure argument.');
eml_lib_assert(isa(A,'float') && isa(B,'float'), ...
    'MATLAB:linsolve:inputType', ...
    'First and second arguments must be single or double.');
eml_lib_assert(ndims(A) == 2 && ndims(B) == 2, ...
    'MATLAB:linsolve:inputDim', ...
    'First and second arguments must be 2D.');
mA = cast(size(A,1),eml_index_class);
nA = cast(size(A,2),eml_index_class);
mB = cast(size(B,1),eml_index_class);
nB = cast(size(B,2),eml_index_class);
minszA = min(mA,nA);
RREQ = nargout == 2;
ONE = ones(eml_index_class);
CZERO = eml_scalar_eg(A,B);
CONE = CZERO + 1;
if nargin > 2
    eml_assert(isstruct(varargin{1}), ...
        'Third argument must be a structure array.');
    eml_assert(isscalar(varargin{1}), ...
        'Embedded MATLAB only supports a scalar structure input.');
    eml_assert(eml_is_const(varargin{1}), ...
        ['Third argument must be a constant.  Try using the STRUCT ', ...
        'function to create the options structure.']);
    eml_prefer_const(varargin);
end
parms = struct( ...
    'LT',uint32(0), ...
    'UT',uint32(0), ...
    'UHESS',uint32(0), ...
    'SYM',uint32(0), ...
    'POSDEF',uint32(0), ...
    'RECT',uint32(0), ...
    'TRANSA',uint32(0));
poptions = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',true, ...
    'PartialMatching',true);
pstruct = eml_parse_parameter_inputs(parms,poptions,varargin{:});
LT = eml_get_parameter_value(pstruct.LT,false,varargin{:});
UT = eml_get_parameter_value(pstruct.UT,false,varargin{:});
UHESS = eml_get_parameter_value(pstruct.UHESS,false,varargin{:});
SYM = eml_get_parameter_value(pstruct.SYM,false,varargin{:});
POSDEF = eml_get_parameter_value(pstruct.POSDEF,false,varargin{:});
RECT = eml_get_parameter_value(pstruct.RECT,false,varargin{:});
TRANSA = eml_get_parameter_value(pstruct.TRANSA,false,varargin{:});
%   LT  UT  UHESS  SYM  POSDEF  RECT  TRANSA
%   ----------------------------------------
%   T   F   F      F    F       T/F   T/F
%   F   T   F      F    F       T/F   T/F
%   F   F   T      F    F       F     T/F
%   F   F   F      T    T/F     F     T/F
%   F   F   F      F    F       T/F   T/F
eml_assert( ...
    islogical(LT) && isscalar(LT) && ...
    islogical(UT) && isscalar(UT) && ...
    islogical(UHESS) && isscalar(UHESS) && ...
    islogical(SYM) && isscalar(SYM) && ...
    islogical(POSDEF) && isscalar(POSDEF) && ...
    islogical(RECT) && isscalar(RECT) && ...
    islogical(TRANSA) && isscalar(TRANSA), ...
    'Structure field must contain logical scalar.');
eml_lib_assert( ...
    (~LT || ~(UT || UHESS || SYM || POSDEF)) && ...
    (~UT || ~(LT || UHESS || SYM || POSDEF)) && ...
    (~UHESS || ~(LT || UT || SYM || POSDEF || RECT)) && ...
    (~SYM || ~(LT || UT || UHESS || RECT)) && ...
    (~POSDEF || (SYM && ~(LT || UT || UHESS || RECT))), ...
    'MATLAB:linsolve:CombinationOfFieldsNotCurrentlySupported', ...
    ['The option selected by the combination of fields in the ', ...
    'structure array is currently not supported.']);
eml_lib_assert((~TRANSA && mA == mB) || (TRANSA && nA == mB), ...
    'MATLAB:dimagree', ...
    'Matrix dimensions must agree.');
if TRANSA
    mC = mA;
else
    mC = nA;
end
if LT
    % RECT is ignored.
    C = eml.nullcopy(eml_expand(CZERO,[mC,nB]));
    for j = 1:nB
        for i = 1:minszA
            C(i,j) = B(i,j);
        end
        for i = eml_index_plus(minszA,1):mC
            C(i,j) = 0;
        end
    end
    if TRANSA
        % inv(U)*C --> C
        C = eml_xtrsm('L','L','C','N',minszA,nB,CONE,A,ONE,mA,C,ONE,mC);
        if RREQ
            r = crude_rcond_triangular(A);
        elseif any_diag_zero(A)
            warn_singular;
        end
    else
        % inv(L)*C --> C
        C = eml_xtrsm('L','L','N','N',minszA,nB,CONE,A,ONE,mA,C,ONE,mC);
        if RREQ
            r = crude_rcond_triangular(A);
        elseif any_diag_zero(A)
            warn_singular;
        end
    end
elseif UT
    % RECT is ignored.
    C = eml.nullcopy(eml_expand(CZERO,[mC,nB]));
    for j = 1:nB
        for i = 1:minszA
            C(i,j) = B(i,j);
        end
        for i = eml_index_plus(minszA,1):mC
            C(i,j) = 0;
        end
    end
    if TRANSA
        % inv(L)*C --> C
        C = eml_xtrsm('L','U','C','N',minszA,nB,CONE,A,ONE,mA,C,ONE,mC);
        if RREQ
            r = crude_rcond_triangular(A);
        elseif any_diag_zero(A)
            warn_singular;
        end
    else
        % inv(U)*C --> C
        C = eml_xtrsm('L','U','N','N',minszA,nB,CONE,A,ONE,mA,C,ONE,mC);
        if RREQ
            r = crude_rcond_triangular(A);
        elseif any_diag_zero(A)
            warn_singular;
        end
    end
elseif SYM
    eml_lib_assert(mA == nA, ...
        'MATLAB:square', ...
        'Matrix must be square.');
    if POSDEF
        % TODO:  xPOTRS, xPOCON
        % Symmetrize to triu(A), since we don't use a symmetric solver yet.
        for j = ONE:nA
            for i = eml_index_plus(j,1):mA
                A(i,j) = conj(A(j,i));
            end
        end
        if TRANSA
            if RREQ
                [C,r] = eml_lusolve(A',B,RREQ);
            else
                C = eml_lusolve(A',B,RREQ);
            end
        else
            if RREQ
                [C,r] = eml_lusolve(A,B,RREQ);
            else
                C = eml_lusolve(A,B,RREQ);
            end
        end
    else
        % TODO:  xSYTRS, xSYTRF, xSYCON
        % Symmetrize to tril(A), since we don't use a symmetric solver yet.
        for j = ONE:nA
            for i = eml_index_plus(j,1):mA
                A(j,i) = conj(A(i,j));
            end
        end
        if TRANSA
            if RREQ
                [C,r] = eml_lusolve(A',B,RREQ);
            else
                C = eml_lusolve(A',B,RREQ);
            end
        else
            if RREQ
                [C,r] = eml_lusolve(A,B,RREQ);
            else
                C = eml_lusolve(A,B,RREQ);
            end
        end
    end
elseif UHESS
    % TODO:  Specialized Hessenberg solver.
    eml_lib_assert(mA == nA, ...
        'MATLAB:square', ...
        'Matrix must be square.');
    A = triu(A,-1);
    if TRANSA
        C = eml_lusolve(A',B,RREQ);
    else
        C = eml_lusolve(A,B,RREQ);
    end
    if RREQ
        r = crude_rcond_triangular(lu(A));
    end
else
    if RECT || (nargin == 2 && mA ~= nA)
        if TRANSA
            [C,r] = eml_qrsolve(A',B,RREQ);
        else
            [C,r] = eml_qrsolve(A,B,RREQ);
        end
    else
        eml_lib_assert(mA == nA, ...
            'MATLAB:square', ...
            'Matrix must be square.');
        if TRANSA
            if RREQ
                [C,r] = eml_lusolve(A',B,RREQ);
            else
                C = eml_lusolve(A',B,RREQ);
            end
        else
            if RREQ
                [C,r] = eml_lusolve(A,B,RREQ);
            else
                C = eml_lusolve(A,B,RREQ);
            end
        end
    end
end

%--------------------------------------------------------------------------

function p = any_diag_zero(A)
for k = ones(eml_index_class):min(size(A))
    if A(k,k) == zeros(class(A))
        p = true;
        return
    end
end
p = false;

%--------------------------------------------------------------------------

function warn_singular
eml_warning('MATLAB:singularMatrix', ...
    'Matrix is singular to working precision.');

%--------------------------------------------------------------------------

function r = crude_rcond_triangular(A)
if isempty(A)
    r = eml_guarded_inf(class(A));
else
    mx = abs(A(1));
    mn = mx;
    for k = cast(2,eml_index_class):min(size(A))
        absAkk = abs(A(k,k));
        if absAkk > mx || isnan(absAkk);
            mx = absAkk;
        elseif absAkk < mn
            mn = absAkk;
        end
    end
    r = mn / mx;
end
%--------------------------------------------------------------------------
