function M = checkABCDE(M,MatrixName)
% Checks A,B,C,D,E data is of proper type

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:30 $
if isnumeric(M)
   if ~(strcmp(MatrixName,'d') || all(isfinite(M(:))))
      ctrlMsgUtils.error('Control:ltiobject:ssProperties6',MatrixName)
   end
   % Convert to full double
   if issparse(M)
      ctrlMsgUtils.warning('Control:ltiobject:SSSparse2Full',MatrixName)
      M = full(M);
   end
   M = double(M);
elseif ~isa(M,'StaticModel')
   if isa(M,'InputOutputModel')
      ctrlMsgUtils.error('Control:lftmodel:ss1',MatrixName)
   else
      ctrlMsgUtils.error('Control:ltiobject:ssProperties6',MatrixName)
   end
end
