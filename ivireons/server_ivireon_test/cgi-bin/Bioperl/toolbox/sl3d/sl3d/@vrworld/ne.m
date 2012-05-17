function x = ne(A, B)
%NE True for nonequal VRWORLD objects.
%   NE(A,B) tests for nonequality of VRWORLD objects.
%   See EQ for detailed description.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:11:06 $ $Author: batserve $

x = ~eq(A, B);
