function Terms = c2dUpdateTerm(Terms,N,coeff)
% Utility for ZOH, FOH, and IMP C2D discretization.
%
% If TERMS(j).delay=N for some j, adds COEFF to TERMS(j).coeff.
% Otherwise, sets TERMS(end+1).coeff=COEFF after growing 
% TERMS.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:12 $
nt = length(Terms);

% Locate delay N
j = 1;
while j<=nt && Terms(j).delay>=0 && Terms(j).delay~=N
   j = j+1;
end

% Grow TERMS if necessary, adding a block of length 50 at a time
% to minimize amount of copy
if j>nt
   % Add block of length 50 to minimize amount of copy
   c = cell(50,1);  c(:) = {-1};
   Terms = [Terms ; struct('delay',c,'coeff',0)];
end

% Update coeff
Terms(j).delay = N;  % could be -1
Terms(j).coeff = Terms(j).coeff + coeff;
