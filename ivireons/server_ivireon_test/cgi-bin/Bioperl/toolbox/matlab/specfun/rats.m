function S = rats(X,lens)
%RATS   Rational output.
%   RATS(X,LEN) uses RAT to display rational approximations to
%   the elements of X.  The string length for each element is LEN.
%   The default is LEN = 13, which allows 6 elements in 78 spaces.
%   Asterisks are used for elements which can't be printed in the
%   allotted space, but which are not negligible compared to the other
%   elements in X.
%
%   The same algorithm, with the default LEN, is used internally
%   by MATLAB for FORMAT RAT.
%
%   Class support for input X:
%      float: double, single
%
%   See also FORMAT, RAT.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.17.4.2 $  $Date: 2009/03/16 22:18:40 $

if nargin < 2, lens = 13; end
lhalf = (lens-1)/2;
tol = min(10^(-lhalf) * norm(X(isfinite(X)),1),.1);
[N,D] = rat(X,tol);
[m,n] = size(X);
nform = ['%' num2str(fix(lhalf)) '.0f'];
dform = ['%-' num2str(fix(lhalf)) '.0f'];
S = [];
for i = 1:m
    s = [];
    for j = 1:n
        if D(i,j) ~= 1
            sj = [lpad(sprintf(nform,N(i,j)),floor(lhalf)) '/' ...
                  rpad(sprintf(dform,D(i,j)),ceil(lhalf))];
        else
            sj = cpad(sprintf('%1.0f',N(i,j)),lens);
        end
        if length(sj) > lens
            sj = cpad('*',lens);
        end
        s = [s ' ' sj];
    end
    S(i,:) = s;
end
S = char(S);


%-----------------------------
function t = lpad(s,len)
%LPAD Left pad with blanks.

t = [blanks(len-length(s)) s];


%-----------------------------
function t = rpad(s,len)
%RPAD Right pad with blanks.

t = [s blanks(len-length(s))];


%----------------------------
function t = cpad(s,len)
%CPAD Pad and center string with blanks.

padding = len-length(s);
t = [blanks(floor(padding/2)) s blanks(ceil(padding/2))];
