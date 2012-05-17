function [A,B,ilo,ihi,rscale] = eml_matlab_zggbal(A,B)
%Embedded MATLAB Private Function

% ZGGBAL balances a pair of general complex matrices (A,B).
% This specialized version only performs the similarity transformations to
% isolate eigenvalues in the first 1 to ILO-1 and last IHI+1 to N
% elements on the diagonal.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

n = cast(size(A,1),eml_index_class);
rscale = zeros(n,1,eml_index_class);
ilo = ones(eml_index_class);
ihi = n;
if n <= 1
    ilo = ones(eml_index_class);
    ihi = ones(eml_index_class);
    rscale(1) = ones(eml_index_class);
    return
end
while true
    [i,j,found] = eml_zggbal_eigsearch_rows(A,B,ihi);
    if ~found
        break
    end
    [A,B] = eml_zggbal_simtran(A,B,ihi,i,j,ilo,ihi);
    rscale(ihi) = j;
    ihi = eml_index_minus(ihi,ones(eml_index_class));
    if ihi == 1
        rscale(ihi) = ihi;
        return
    end
end
while true
    [i,j,found] = eml_zggbal_eigsearch_cols(A,B,ilo,ihi);
    if ~found
        break
    end
    [A,B] = eml_zggbal_simtran(A,B,ilo,i,j,ilo,ihi);
    rscale(ilo) = j;
    ilo = eml_index_plus(ilo,ones(eml_index_class));
    if ilo == ihi
        rscale(ilo) = ilo;
        return
    end
end

%--------------------------------------------------------------------------

function [A,B] = eml_zggbal_simtran(A,B,m,i,j,ilo,ihi)
% Subfunction to eml_zggbal.  In matrices A and B, swaps rows i and m
% (from columns ilo:n) and columns j and m (from rows 1:ihi).
eml_must_inline;
n = cast(size(A,1),eml_index_class);
isgen = ~(eml_is_const(size(B)) && isempty(B));
if i ~= m
    % Permute rows m and i
    % A([i,m],ilo:n) = A([m,i],ilo:n);
    for k = ilo : n
        atmp = A(i,k);
        A(i,k) = A(m,k);
        A(m,k) = atmp;
    end
    if isgen
        % B([i,m],ilo:n) = B([m,i],ilo:n);
        for k = ilo : n
            btmp = B(i,k);
            B(i,k) = B(m,k);
            B(m,k) = btmp;
        end
    end
end
if j ~= m
    % Permute columns m and j
    % A(1:ihi,[j,m]) = A(1:ihi,[m,j]);
    for k = ones(eml_index_class) : ihi
        atmp = A(k,j);
        A(k,j) = A(k,m);
        A(k,m) = atmp;
    end
    if isgen
        % B(1:ihi,[j,ilo]) = B(1:ihi,[ilo,j]);
        for k = ones(eml_index_class) : ihi
            btmp = B(k,j);
            B(k,j) = B(k,m);
            B(k,m) = btmp;
        end
    end
end

%--------------------------------------------------------------------------

function [i,j,found] = eml_zggbal_eigsearch_cols(A,B,ilo,ihi)
% Subfunction to eml_zggbal.  Find column with one nonzero element (or no
% nonzero elements) in rows ilo through ihi.
eml_must_inline;
i = zeros(eml_index_class);
j = zeros(eml_index_class);
found = false;
isgen = ~(eml_is_const(size(B)) && isempty(B));
for jj = ilo : ihi
    nzcount = 0;
    i = ihi;
    j = jj;
    for ii = ilo : ihi
        if (A(ii,jj) ~= 0) || (isgen && (B(ii,jj) ~= 0)) || (~isgen && (ii == jj))
            if nzcount == 0
                % Save the location.
                i = ii;
                nzcount = 1;
            else
                % Found another nonzero.  Abandon this column and move on.
                nzcount = 2;
                break
            end
        end
    end
    if nzcount < 2
        found = true;
        break
    end
end

%--------------------------------------------------------------------------

function [i,j,found] = eml_zggbal_eigsearch_rows(A,B,ihi)
% Subfunction to eml_zggbal.  Find row with one nonzero element
% (or no nonzero elements) in columns 1 through ihi.
eml_must_inline;
i = zeros(eml_index_class);
j = zeros(eml_index_class);
found = false;
isgen = ~(eml_is_const(size(B)) && isempty(B));
ii = ihi;
while ii > zeros(eml_index_class) % for ii = ihi : -1 : ONE
    nzcount = 0;
    i = ii;
    j = ihi;
    for jj = ones(eml_index_class) : ihi
        if (A(ii,jj) ~= 0) || (isgen && (B(ii,jj) ~= 0)) || (~isgen && (ii == jj))
            if nzcount == 0
                % Save the location.
                j = jj;
                nzcount = 1;
            else
                % Found another nonzero.  Abandon this row and move on.
                nzcount = 2;
                break
            end
        end
    end
    if nzcount < 2
        found = true;
        break
    end
    ii = eml_index_minus(ii,ones(eml_index_class));
end

%--------------------------------------------------------------------------
