function M = vertcat(varargin)
%VERTCAT  Vertical concatenation of input/output models.
%
%   M = VERTCAT(M1,M2,...) performs the concatenation operation
%   [M1 ; M2 ; ...].
% 
%   See also INPUTOUTPUTMODEL/HORZCAT, STACK, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:36 $
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
         iosj = Mj.IOSize_;
         if any(iosj)
            % Skip empty 0x0 models. Needed for [[];M] to work while guaranteeing that
            % [ss(zeros(2,0)) ; zeros(2,0)] is 4x0
            if ~any(M.IOSize_)
               % M is 0x0. Use MJ instead
               M = Mj;
            elseif M.IOSize_(2)~=iosj(2)
               ctrlMsgUtils.error('Control:combination:vertcat1');
            else
               % Combine data and metadata
               M = iocat_(1,M,Mj); % overloadable since M and Mj are of the same class
               M = iocatMetaData(1,M,Mj);
               M.IOSize_(1) = M.IOSize_(1) + Mj.IOSize_(1);
            end
         end
      end
   else
      % Harmonize types and try again
      [varargin{1:ni}] = ltipack.matchType('cat',varargin{:});
      M = vertcat(varargin{:});
   end
catch E
   throw(E)
end