function yEst = fitvector(lam,xdata,ydata)
%FITVECTOR  Used by DATDEMO to return value of fitting function.
%   yEst = FITVECTOR(lam,xdata) returns the value of the fitting function, y
%   (defined below), at the data points xdata with parameters set to lam.
%   yEst is returned as a N-by-1 column vector, where N is the number of
%   data points.
%
%   FITVECTOR assumes the fitting function, y, takes the form
%
%     y =  c(1)*exp(-lam(1)*t) + ... + c(n)*exp(-lam(n)*t)
%
%   with n linear parameters c, and n nonlinear parameters lam.
%
%   To solve for the linear parameters c, we build a matrix A
%   where the j-th column of A is exp(-lam(j)*xdata) (xdata is a vector).
%   Then we solve A*c = ydata for the linear least-squares solution c,
%   where ydata is the observed values of y.

A = zeros(length(xdata),length(lam));  % build A matrix
for j = 1:length(lam)
   A(:,j) = exp(-lam(j)*xdata);
end
c = A\ydata; % solve A*c = y for linear parameters c
yEst = A*c; % return the estimated response based on c