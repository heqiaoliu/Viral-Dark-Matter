function M = stack(arraydim,varargin)
%STACK  Stacks input/output models into model array.
%
%   M = STACK(ARRAYDIM,M1,M2,...) produces an array M of input/output models 
%   by stacking the models M1,M2,... along the array dimension ARRAYDIM.  
%   All models must have the same number of inputs and outputs and the I/O 
%   dimensions are not counted as array dimensions.
%
%   For example, if M1 and M2 are two models with the same I/O sizes,
%     * STACK(1,M1,M2) produces a 2-by-1 array
%     * STACK(2,M1,M2) produces a 1-by-2 array
%     * STACK(3,M1,M2) produces a 1-by-1-by-2 array.
%
%   You can also use STACK to concatenate the model arrays M1,M2,... along
%   the array dimension ARRAYDIM.
%
%   See also INPUTOUTPUTMODEL/HORZCAT, INPUTOUTPUTMODEL/VERTCAT, APPEND, 
%   INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:35 $
ni = nargin-1;

% Offset by the two I/O dimensions
if ~(isscalar(arraydim) && isnumeric(arraydim) && arraydim>0 && rem(arraydim,1)==0)
   ctrlMsgUtils.error('Control:combination:stack1')
elseif ni<2
   M = varargin{1};  return
end

try
   if ltipack.hasMatchingType('stack',varargin{:})
      % All operands are of the same type
      M = varargin{1};
      for j=2:ni
         Mj = varargin{j};
         if ~isequal(M.IOSize_,Mj.IOSize_),
            ctrlMsgUtils.error('Control:combination:stack2')
         end
         % Combine data and metadata
         M = stack_(arraydim,M,Mj);
         M = plusMetaData(M,Mj);
      end
   else
      % Harmonize types and try again
      [varargin{1:ni}] = ltipack.matchType('stack',varargin{:});
      M = stack(arraydim,varargin{:});
   end
catch E
   throw(E)
end

