function M = append(varargin)
%APPEND  Appends model inputs and outputs. 
%
%   M = APPEND(M1,M2, ...) constructs the aggregate model
% 
%                 [ M1  0  .. 0 ]
%             M = [  0  M2      ]
%                 [  :      .   ]
%                 [  0        . ]
%
%   by concatenating the input and output vectors of the models M1, M2,... 
%   APPEND takes any combination of input/output model types (see
%   INPUTOUTPUTMODEL for an overview of available types). 
%
%   If M1,M2,... are arrays of models, APPEND returns a model array M of 
%   the same size where 
%      M(:,:,k) = APPEND(M1(:,:,k),M2(:,:,k),...) .
%
%   See also INPUTOUTPUTMODEL/BLKDIAG, SERIES, PARALLEL, FEEDBACK, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:21 $
ni = nargin;
if ni<2
   M = varargin{1};  return
end

try
   if ltipack.hasMatchingType('cat',varargin{:})
      % All operands are of the same type
      M = varargin{1};
      for j=2:ni
         Mj = varargin{j};
         % Combine data and metadata
         M = append_(M,Mj); % overloadable since M and Mj are of the same class
         M = iocatMetaData([1 2],M,Mj);
         M.IOSize_ = M.IOSize_ + Mj.IOSize_;
      end
   else
      % Harmonize types and try again
      [varargin{1:ni}] = ltipack.matchType('cat',varargin{:});
      M = append(varargin{:});
   end
catch E
   throw(E)
end

