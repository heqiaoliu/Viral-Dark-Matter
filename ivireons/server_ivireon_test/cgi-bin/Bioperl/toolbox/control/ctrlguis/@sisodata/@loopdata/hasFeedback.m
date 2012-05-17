function boo = hasFeedback(this)
% Returns a boolean vector with true for compensator with
% feedback and false otherwise.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:48:10 $
nL = length(this.L);
boo = false(nL,1);
for ct=1:nL
   boo(ct) = this.L(ct).Feedback;
end
