function sys = fcat(varargin)
% FCAT  Concatenates FRD models along the frequency dimension. 
% 
%    SYS = FCAT(SYS1,SYS2,...) takes two or more FRD models and 
%    merges their frequency responses into a single FRD model SYS.   
%    The frequency vectors of SYS1, SYS2,... should not intersect 
%    and are merged together.  The resulting frequency vector is 
%    sorted by increasing frequency. 
% 
%    See also FSELECT, FRDMODEL/INTERP, FRD. 

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:35:57 $
ni = nargin;

% Check that all models are FRD
if ~all(cellfun(@(sys) isa(sys,'FRDModel'),varargin))
   % REVISIT: generalize error message
   ctrlMsgUtils.error('Control:combination:fcat1')
elseif ni<2
   sys = varargin{1};  return
end

try
   if ltipack.hasMatchingType('stack',varargin{:})
      sys = varargin{1};
      for j=2:ni
         sysj = varargin{j};
         if ~isequal(sys.IOSize_,sysj.IOSize_),
            ctrlMsgUtils.error('Control:combination:fcat2')
         end
         % Combine data
         sys = fcat_(sys,sysj);
         % Combine metadata
         sys.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys.TimeUnit_,sysj.TimeUnit_);
         sys = plusInput(sys,sysj);
         sys = plusOutput(sys,sysj);
      end
      sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
   else
      % Harmonize types and try again
      [varargin{1:ni}] = ltipack.matchType('stack',varargin{:});
      sys = fcat(varargin{:});
   end
catch E
   throw(E)
end
