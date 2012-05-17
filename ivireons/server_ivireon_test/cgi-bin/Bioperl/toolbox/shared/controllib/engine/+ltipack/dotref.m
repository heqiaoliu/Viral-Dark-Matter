function result = dotref(M,Struct)
% Safe implementation of recursive SUBREF calls. Ensures that 
% InputOutputModel/subsref is invoked for downstream references to 
% InputOutputModel properties, e.g., in sys.Uncertainty.a.Nominal

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:35 $
result = subsref(M,Struct);
