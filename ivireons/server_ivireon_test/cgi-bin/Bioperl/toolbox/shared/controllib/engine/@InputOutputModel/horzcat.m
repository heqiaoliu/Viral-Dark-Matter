function M = horzcat(varargin)
%HORZCAT  Horizontal concatenation of input/output models.
%
%   M = HORZCAT(M1,M2,...) performs the concatenation operation
%   [M1 , M2 , ...].
% 
%   See also INPUTOUTPUTMODEL/VERTCAT, STACK, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:25 $

% Do not overload this method, overload iocat_ instead.
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
            % Skip empty 0x0 models. Needed for [[] , M] to work while guaranteeing that
            % [ss(zeros(0,2)),zeros(0,2)] is 0x4
            if ~any(M.IOSize_)
               % M is 0x0. Use MJ instead
               M = Mj;
            elseif M.IOSize_(1)~=iosj(1)
               ctrlMsgUtils.error('Control:combination:horzcat1')
            else
               % Combine data and metadata
               M = iocat_(2,M,Mj); % overloadable since M and Mj are of the same class
               M = iocatMetaData(2,M,Mj);
               M.IOSize_(2) = M.IOSize_(2) + Mj.IOSize_(2);
            end
         end
      end
   else
      % Harmonize types and try again
      [varargin{1:ni}] = ltipack.matchType('cat',varargin{:});
      M = horzcat(varargin{:});
   end
catch E
   throw(E)
end