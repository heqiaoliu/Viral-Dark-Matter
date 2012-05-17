function x = ne(A, B)
%NE True for nonequal VRFIGURE handles.
%   NE(A,B) tests for nonequality of VRFIGURE handles.
%   See VRFIGURE/EQ for detailed description.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:08 $ $Author: batserve $

x = ~eq(A, B);
