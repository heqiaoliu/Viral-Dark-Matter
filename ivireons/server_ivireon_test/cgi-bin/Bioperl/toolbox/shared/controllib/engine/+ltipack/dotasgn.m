function M = dotasgn(M,Struct,rhs)
% Safe implementation of recursive SUBSASGN calls. In
% sys.Uncertainty.a.Nominal = 2, ensures that the "Nominal"
% property is properly handled by InputOutputModel/subsasgn. 

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:34 $
M = subsasgn(M,Struct,rhs);
