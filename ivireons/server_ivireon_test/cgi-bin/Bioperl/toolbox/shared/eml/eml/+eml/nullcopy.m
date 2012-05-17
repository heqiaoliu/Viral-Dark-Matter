function A = nullcopy(A)
%EML.NULLCOPY Create an uninitialized copy in Embedded MATLAB
%
%   X = EML.NULLCOPY(A) copies the class, size, and all other attributes of
%   A to X.  In Embedded MATLAB, it does not copy element values.
% 
%   Note: EML.NULLCOPY produces uninitialized memory.  You are responsible
%   for initializing memory before it is read.  Failing to do so is
%   dangerous and may lead to unpredictable behavior. It is recommended
%   that EML.NULLCOPY only be used when undesirable initialization is
%   observed in the generated code.
%
%   EML.NULLCOPY can only be used immediately on the right-hand side of a
%   complete assignment.
%
%   In MATLAB, EML.NULLCOPY(A) returns A.
% 
%   Example:
%
%     % EML.NULLCOPY prevents the initialization of X with zeros.
%     N = 5;
%     X = eml.nullcopy(zeros(1,N));
%     for i = 1:N
%        if mod(i,2) == 0
%           X(i) = i;
%        else
%           X(i) = 0;
%        end
%     end

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:02:58 $
