function B = eml_refblas_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xTRSM(SIDE,UPLO,TRANSA,DIAGA,M,N,ALPHA1,A(IA0),LDA,B(IB0),LDB)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 13, 'Not enough input arguments.');
eml_prefer_const(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,ia0,lda,ib0,ldb);
NOCONJ = TRANSA(1) == 'T';
NON_UNIT_A = DIAGA(1) == 'N';
NON_UNIT_ALPHA = alpha1 ~= 1;
if n == 0 || isempty(B)
    return
end
temp = eml_scalar_eg(alpha1,A,B);
Aoffset = eml_index_minus(ia0,1);
Boffset = eml_index_minus(ib0,1);
ONE = ones(eml_index_class);
if alpha1 == 0
    for j = ONE:n
        jBcol = eml_index_plus(Boffset, ...
            eml_index_times(ldb,eml_index_minus(j,1)));
        for i = ONE:m
            B(eml_index_plus(i,jBcol)) = 0;
        end
    end
    return
end
% Start the operations.
if SIDE(1) == 'L'
    if TRANSA(1) == 'N'
        % Form B := alpha1*inv(A)*B.
        if UPLO(1) == 'U'
            for j = ONE:n
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                if NON_UNIT_ALPHA
                    for i = ONE:m
                        B(eml_index_plus(i,jBcol)) =  ...
                            alpha1.*B(eml_index_plus(i,jBcol));
                    end
                end
                for k = m:-1:ONE
                    kAcol = eml_index_plus(Aoffset, ...
                        eml_index_times(lda,eml_index_minus(k,1)));
                    if B(eml_index_plus(k,jBcol))~=0
                        if NON_UNIT_A
                            B(eml_index_plus(k,jBcol)) = eml_div( ...
                                B(eml_index_plus(k,jBcol)), ...
                                A(eml_index_plus(k,kAcol)));
                        end
                        for i = ONE:eml_index_minus(k,1)
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                B(eml_index_plus(k,jBcol)) .* ...
                                A(eml_index_plus(i,kAcol));
                        end
                    end
                end
            end
        else
            for j = ONE:n
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                if NON_UNIT_ALPHA
                    for i = ONE:m
                        B(eml_index_plus(i,jBcol)) = ...
                            alpha1.*B(eml_index_plus(i,jBcol));
                    end
                end
                for k = ONE:m
                    kAcol = eml_index_plus(Aoffset, ...
                        eml_index_times(lda,eml_index_minus(k,1)));
                    if B(eml_index_plus(k,jBcol))~=0
                        if NON_UNIT_A
                            B(eml_index_plus(k,jBcol)) = eml_div( ...
                                B(eml_index_plus(k,jBcol)), ...
                                A(eml_index_plus(k,kAcol)));
                        end
                        for i = eml_index_plus(k,1):m
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                B(eml_index_plus(k,jBcol)) .* ...
                                A(eml_index_plus(i,kAcol));
                        end
                    end
                end
            end
        end
    else
        % Form  B := alpha1*inv(A')*B
        % or    B := alpha1*inv(conjg(A'))*B.
        if UPLO(1) == 'U'
            for j = ONE:n
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                for i = ONE:m
                    iAcol = eml_index_plus(Aoffset, ...
                        eml_index_times(lda,eml_index_minus(i,1)));
                    temp(1) = alpha1.*B(eml_index_plus(i,jBcol));
                    if NOCONJ
                        for k = ONE:eml_index_minus(i,1)
                            temp(1) = temp - ...
                                A(eml_index_plus(k,iAcol)) .* ...
                                B(eml_index_plus(k,jBcol));
                        end
                        if NON_UNIT_A
                            temp(1) = eml_div(temp, ...
                                A(eml_index_plus(i,iAcol)));
                        end
                    else
                        for k = ONE:eml_index_minus(i,1)
                            temp(1) = temp - eml_conjtimes( ...
                                A(eml_index_plus(k,iAcol)), ...
                                B(eml_index_plus(k,jBcol)));
                        end
                        if NON_UNIT_A
                            temp(1) = eml_div(temp, ...
                                conj(A(eml_index_plus(i,iAcol))));
                        end
                    end
                    B(eml_index_plus(i,jBcol)) = temp;
                end
            end
        else
            for j = ONE:n
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                for i = m:-1:ONE
                    iAcol = eml_index_plus(Aoffset, ...
                        eml_index_times(lda,eml_index_minus(i,1)));
                    temp(1) = alpha1.*B(eml_index_plus(i,jBcol));
                    if NOCONJ
                        for k = eml_index_plus(i,1):m
                            temp(1) = temp - ...
                                A(eml_index_plus(k,iAcol)) .* ...
                                B(eml_index_plus(k,jBcol));
                        end
                        if NON_UNIT_A
                            temp(1) = eml_div(temp, ...
                                A(eml_index_plus(i,iAcol)));
                        end
                    else
                        for k = eml_index_plus(i,1):m
                            temp(1) = temp - eml_conjtimes( ...
                                A(eml_index_plus(k,iAcol)), ...
                                B(eml_index_plus(k,jBcol)));
                        end
                        if NON_UNIT_A
                            temp(1) = eml_div(temp, ...
                                conj(A(eml_index_plus(i,iAcol))));
                        end
                    end
                    B(eml_index_plus(i,jBcol)) = temp;
                end
            end
        end
    end
else
    if TRANSA(1) == 'N'
        % Form  B := alpha1*B*inv(A).
        if UPLO(1) == 'U'
            for j = ONE:n
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                jAcol = eml_index_plus(Aoffset, ...
                    eml_index_times(lda,eml_index_minus(j,1)));
                if NON_UNIT_ALPHA
                    for  i = ONE:m
                        B(eml_index_plus(i,jBcol)) = ...
                            alpha1.*B(eml_index_plus(i,jBcol));
                    end
                end
                for k = ONE:eml_index_minus(j,1)
                    kBcol = eml_index_plus(Boffset, ...
                        eml_index_times(ldb,eml_index_minus(k,1)));
                    if A(eml_index_plus(k,jAcol))~=0
                        for i = ONE:m
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                A(eml_index_plus(k,jAcol)) .* ...
                                B(eml_index_plus(i,kBcol));
                        end
                    end
                end
                if NON_UNIT_A
                    temp(1) = eml_div(1,A(eml_index_plus(j,jAcol)));
                    for  i = ONE:m
                        B(eml_index_plus(i,jBcol)) = ...
                            temp.*B(eml_index_plus(i,jBcol));
                    end
                end
            end
        else
            for j = n:-1:ONE
                jBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(j,1)));
                jAcol = eml_index_plus(Aoffset, ...
                    eml_index_times(lda,eml_index_minus(j,1)));
                if NON_UNIT_ALPHA
                    for i = ONE:m
                        B(eml_index_plus(i,jBcol)) = ...
                            alpha1.*B(eml_index_plus(i,jBcol));
                    end
                end
                for k = eml_index_plus(j,1):n
                    kBcol = eml_index_plus(Boffset, ...
                        eml_index_times(ldb,eml_index_minus(k,1)));
                    if A(eml_index_plus(k,jAcol))~=0
                        for  i = ONE:m
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                A(eml_index_plus(k,jAcol)) .* ...
                                B(eml_index_plus(i,kBcol));
                        end
                    end
                end
                if NON_UNIT_A
                    temp(1) = eml_div(1,A(eml_index_plus(j,jAcol)));
                    for i = ONE:m
                        B(eml_index_plus(i,jBcol)) = ...
                            temp.*B(eml_index_plus(i,jBcol));
                    end
                end
            end
        end
    else
        % Form B := alpha1*B*inv(A')
        % or   B := alpha1*B*inv(conjg(A')).
        if UPLO(1) == 'U'
            for k = n:-1:ONE
                kAcol = eml_index_plus(Aoffset, ...
                    eml_index_times(lda,eml_index_minus(k,1)));
                kBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(k,1)));
                if NON_UNIT_A
                    if NOCONJ
                        temp(1) = eml_div(1,A(eml_index_plus(k,kAcol)));
                    else
                        temp(1) = eml_div(1, ...
                            conj(A(eml_index_plus(k,kAcol))));
                    end
                    for i = ONE:m
                        B(eml_index_plus(i,kBcol)) = ...
                            temp.*B(eml_index_plus(i,kBcol));
                    end
                end
                for j = ONE:eml_index_minus(k,1)
                    jBcol = eml_index_plus(Boffset,...
                        eml_index_times(ldb,eml_index_minus(j,1)));
                    if A(eml_index_plus(j,kAcol))~=0
                        if NOCONJ
                            temp(1) = A(eml_index_plus(j,kAcol));
                        else
                            temp(1) = conj(A(eml_index_plus(j,kAcol)));
                        end
                        for  i = ONE:m
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                temp.*B(eml_index_plus(i,kBcol));
                        end
                    end
                end
                if NON_UNIT_ALPHA
                    for i = ONE:m
                        B(eml_index_plus(i,kBcol)) = ...
                            alpha1.*B(eml_index_plus(i,kBcol));
                    end
                end
            end
        else
            for k = ONE:n
                kAcol = eml_index_plus(Aoffset, ...
                    eml_index_times(lda,eml_index_minus(k,1)));
                kBcol = eml_index_plus(Boffset, ...
                    eml_index_times(ldb,eml_index_minus(k,1)));
                if NON_UNIT_A
                    if NOCONJ
                        temp(1) = eml_div(1,A(eml_index_plus(k,kAcol)));
                    else
                        temp(1) = eml_div(1, ...
                            conj(A(eml_index_plus(k,kAcol))));
                    end
                    for i = ONE:m
                        B(eml_index_plus(i,kBcol)) = ...
                            temp.*B(eml_index_plus(i,kBcol));
                    end
                end
                for j = eml_index_plus(k,1):n
                    jBcol = eml_index_plus(Boffset, ...
                        eml_index_times(ldb,eml_index_minus(j,1)));
                    if A(eml_index_plus(j,kAcol))~=0
                        if NOCONJ
                            temp(1) = A(eml_index_plus(j,kAcol));
                        else
                            temp(1) = conj(A(eml_index_plus(j,kAcol)));
                        end
                        for i = ONE:m
                            B(eml_index_plus(i,jBcol)) = ...
                                B(eml_index_plus(i,jBcol)) - ...
                                temp.*B(eml_index_plus(i,kBcol));
                        end
                    end
                end
                if NON_UNIT_ALPHA
                    for i = ONE:m
                        B(eml_index_plus(i,kBcol)) = ...
                            alpha1.*B(eml_index_plus(i,kBcol));
                    end
                end
            end
        end
    end
end
