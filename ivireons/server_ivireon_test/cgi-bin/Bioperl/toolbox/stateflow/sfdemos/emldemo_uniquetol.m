function B = emldemo_uniquetol(A,tol)
% Return a unique version of A where elements are unique to within TOL of
% each other.  That is abs(B(i) - B(j)) > tol for all i,j.
%#eml

A = sort(A);

eml.varsize('B',[1 100]);
B = A(1);
k = 1;
for i = 2:length(A)
    if abs(A(k) - A(i)) > tol
        B = [B A(i)];
        k = i;
    end
end
