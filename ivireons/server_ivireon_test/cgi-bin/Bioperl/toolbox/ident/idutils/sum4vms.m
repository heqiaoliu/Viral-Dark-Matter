function y=sum4vms(x)
%SUM    Sum of the elements.
%   For vectors, SUM(X) is the sum of the elements of X.
%   For matrices, SUM(X) is a row vector with the sum over
%   each column. SUM(DIAG(X)) is the trace of X.
%
%   See also PROD, CUMPROD, CUMSUM.

%   L. Ljung
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2008/10/02 18:52:04 $

if ~any(isnan(x))
  %regular sum
  y=sum(x);
else
  [t1,t2]=size(x);
  if min(t1,t2) == 1
    y=NaN;
  else
    for i=1:t2
      if ~any(isnan(x(:,i)))
        y(i) = sum(x(:,i));
      else
        y(i) = NaN;
      end;
    end;
  end;
end
