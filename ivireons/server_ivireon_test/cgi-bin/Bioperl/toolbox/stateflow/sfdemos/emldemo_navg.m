function B = emldemo_navg(A,n)
% Compute the average of every N elements of A and put them in B.
%#eml

assert(n>=1 && n<=numel(A));

B = zeros(1,numel(A)/n);
k = 1;
for i = 1 : numel(A)/n
     B(i) = mean(A(k + (0:n-1)));
     k = k + n;
end