function M = reshape(M,varargin)
%RESHAPE  Reshapes array of input/output models.
%
%   M = RESHAPE(M,S1,S2,...,Sk) reshapes the model array M into an array of
%   size [S1 S2 ... Sk]. There must be S1*S2*...*Sk models to begin with.
% 
%   M = RESHAPE(M,[S1 S2 ... Sk]) is the same thing.
%
%   See also INPUTOUTPUTMODEL/NDIMS, INPUTOUTPUTMODEL/SIZE, INPUTOUTPUTMODEL/PERMUTE, DYNAMICSYSTEM, STATICMODEL.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:56 $
if nargin<2,
   ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','reshape','InputOutputModel/reshape')
end

try
   M = reshape_(M,varargin{:});
catch E
   switch E.identifier
      case 'MATLAB:class:undefinedMethod'
         ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','reshape',class(M))
      case 'MATLAB:getReshapeDims:notSameNumel'
         if isequal(getArraySize(M),[1 1])
            % g243021
            ctrlMsgUtils.error('Control:ltiobject:reshape1')
         else
            ctrlMsgUtils.error('Control:ltiobject:reshape2')
         end
      otherwise
         throw(E)
   end
end

