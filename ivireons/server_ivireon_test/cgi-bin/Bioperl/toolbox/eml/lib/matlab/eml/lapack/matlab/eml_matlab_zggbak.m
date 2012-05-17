function V = eml_matlab_zggbak(V,ilo,ihi,rscale)
%Embedded MATLAB Private Function

% This specialization of ZGGBAK forms the right eigenvectors of a complex
% generalized eigenvalue problem A*x = lambda*B*x, by backward
% transformation on the computed eigenvectors of the balanced pair of
% matrices output by ZGGBAL.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

IONE = ones(eml_index_class);
n = cast(size(V,1),eml_index_class);
m = cast(size(V,2),eml_index_class);
% backward permutation on right eigenvectors
if ilo > 1
    i = eml_index_minus(ilo,IONE);
    while i >= IONE % for i = ilo-1 : -1 : 1
        k = rscale(i);
        if k ~= i
            % V([i,k],:) = V([k,i],:);
            for j = IONE : m
                tmp = V(i,j);
                V(i,j) = V(k,j);
                V(k,j) = tmp;
            end
        end
        i = eml_index_minus(i,IONE);
    end
end
if ihi < n
    for i = eml_index_plus(ihi,IONE) : n
        k = rscale(i);
        if k ~= i
            % V([i,k],:) = V([k,i],:);
            for j = IONE : m
                tmp = V(i,j);
                V(i,j) = V(k,j);
                V(k,j) = tmp;
            end
        end
    end
end
