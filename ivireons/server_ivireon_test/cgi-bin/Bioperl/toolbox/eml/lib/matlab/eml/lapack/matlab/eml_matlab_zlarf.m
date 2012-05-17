function [C,work] = eml_matlab_zlarf(side,m,n,v,iv0,incv,tau,C,ic0,ldc,work)
%Embedded MATLAB Private Function

%   -- LAPACK auxiliary routine (version 3.2) --
%   xLARF( SIDE, M, N, V, INCV, TAU, C, LDC, WORK )

%   WORK    (workspace) array, same type as C, dimension
%                           (N) if SIDE = 'L'
%                        or (M) if SIDE = 'R'
%   Use v = [] to avoid copies when isequal(v,C).
%   Use the second output to avoid copying "work".

%   Copyright 2007-2010 The MathWorks, Inc.
%#eml

CZERO = eml_scalar_eg(C);
CONE = CZERO + 1;
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
APPLYLEFT = side == 'L';
vinC = eml_is_const(size(v)) && isequal(v,[]);
if tau ~= 0
    % Set up variables for scanning v.  lastv begins pointing to the
    % end of v.
    if APPLYLEFT
        lastv = cast(m,eml_index_class);
    else
        lastv = cast(n,eml_index_class);
    end
    if incv > ZERO
        % i = 1 + (lastv-1) * incv;
        i = eml_index_plus(iv0,eml_index_times(incv,eml_index_minus(lastv,1)));
    else
        i = cast(iv0,eml_index_class);
    end
    % Look for the last non-zero row in v.
    if vinC
        while lastv > ZERO && C(i) == 0
            lastv = eml_index_minus(lastv,1);
            i = eml_index_minus(i,incv);
        end
    else
        while lastv > ZERO && v(i) == 0
            lastv = eml_index_minus(lastv,1);
            i = eml_index_minus(i,incv);
        end
    end
    if APPLYLEFT
        % Scan for the last non-zero column in c(1:lastv,:).
        lastc = ilazlc(lastv,n,C,ic0,ldc);
    else
        % Scan for the last non-zero row in c(:,1:lastv).
        lastc = ilazlr(m,lastv,C,ic0,ldc);
    end
else
    lastv = ZERO;
    lastc = ZERO;
end
% Note that lastc == 0 renders the BLAS operations null; no special case is
% needed at this level.
if APPLYLEFT
    % Form  H * C
    if lastv > ZERO
        % w := C' * v, i.e.,
        % w(1:lastc,1) := C(1:lastv,1:lastc)' * v(1:lastv,1)
        % ZGEMV( 'C', LASTV, LASTC, ONE, C, LDC, V, INCV, ZERO, WORK, 1 )
        if vinC
            work = eml_xgemv('C',lastv,lastc,CONE,C,ic0,ldc,C,iv0,incv,0,work,ONE,ONE);
        else
            work = eml_xgemv('C',lastv,lastc,CONE,C,ic0,ldc,v,iv0,incv,0,work,ONE,ONE);
        end
        % C := C - v * w', i.e.,
        % C(1:lastv,1:lastc) := C(...) - v(1:lastv,1) * w(1:lastc,1)'
        % ZGERC( LASTV, LASTC, -TAU, V, INCV, WORK, 1, C, LDC )
        C = eml_xgerc(lastv,lastc,-tau,v,iv0,incv,work,ONE,ONE,C,ic0,ldc);
    end
else
    % Form  C * H
    if lastv > ZERO
        % w := C * v, i.e.,
        % w(1:lastc,1) := C(1:lastc,1:lastv) * v(1:lastv,1)
        % ZGEMV( 'N', LASTC, LASTV, ONE, C, LDC, V, INCV, ZERO, WORK, 1 )
        if vinC
            work = eml_xgemv('N',lastc,lastv,CONE,C,ic0,ldc,C,iv0,incv,CZERO,work,ONE,ONE);
        else
            work = eml_xgemv('N',lastc,lastv,CONE,C,ic0,ldc,v,iv0,incv,CZERO,work,ONE,ONE);
        end
        % C := C - w * v', i.e.,
        % C(1:lastc,1:lastv) := C(...) - w(1:lastc,1) * v(1:lastv,1)'
        % ZGERC( LASTC, LASTV, -TAU, WORK, 1, V, INCV, C, LDC )
        C = eml_xgerc(lastc,lastv,-tau,work,ONE,ONE,v,iv0,incv,C,ic0,ldc);
    end
end

%--------------------------------------------------------------------------

function j = ilazlc(m,n,A,ia0,lda)
% Find the last nonzero column.
j = cast(n,eml_index_class);
while j > 0
    coltop = eml_index_plus(ia0,eml_index_times(eml_index_minus(j,1),lda));
    colbottom = eml_index_plus(coltop,eml_index_minus(m,1));
    for ia = coltop:colbottom
        if A(ia) ~= 0
            return
        end
    end
    j = eml_index_minus(j,1);
end

%--------------------------------------------------------------------------

function i = ilazlr(m,n,A,ia0,lda)
% Find the last nonzero row.
i = cast(m,eml_index_class);
while i > 0
    rowleft = eml_index_plus(ia0,eml_index_minus(i,1));
    rowright = eml_index_plus( ...
        rowleft, ...
        eml_index_times(eml_index_minus(n,1),lda));
    for ia = rowleft:lda:rowright
        if A(ia) ~= 0
            return
        end
    end
    i = eml_index_minus(i,1);
end

%--------------------------------------------------------------------------
