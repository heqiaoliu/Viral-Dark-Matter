classdef SuspendWarnings < handle
   % Suspends some or all warnings.
   %
   %   H = ctrlMsgUtils.SuspendWarnings caches the current WARNING 
   %   state and turns off all warnings. The original WARNING state
   %   is automatically restored when the variable H is cleared or 
   %   goes out of scope.
   %
   %   H = ctrlMsgUtils.SuspendWarnings(ID1,ID2,...) suspends only
   %   the warnings with identifiers ID1,ID2,... 
   
   %   Copyright 1990-2009 The MathWorks, Inc.
   %   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:11:30 $
   properties
      WarningState    % WARNING state when suspending warnings
%       LastWarning     % LASTWARN message when suspending warnings
%       LastWarningID   % LASTWARN identifier when suspending warnings
%       SuspendedIDs    % IDs of suspended warnings (empty when suspending all warnings)
   end
   
   methods
      function h = SuspendWarnings(varargin)
         % Constructor
         ni = nargin;
         if ni==0
            % Suspending all warnings
            h.WarningState = warning('off'); %#ok<WNOFF>
         else
            % Suspend specified warning IDs
            h.WarningState = warning;
            for ct=1:ni
               warning('off',varargin{ct});
            end
         end
%          h.SuspendedIDs = varargin;
%          [h.LastWarning,h.LastWarningID] = lastwarn;
      end
      
      function delete(h)
         % Restore warning state
         warning(h.WarningState);
%          if isempty(h.SuspendedIDs)
%             lastwarn(h.LastWarning,h.LastWarningID)
%          else
%             [~,lastid] = lastwarn;
%             if any(strcmp(lastid,h.SuspendedIDs))
%                % Revert to last warning before suspension
%                lastwarn(h.LastWarning,h.LastWarningID)
%             end
%          end
      end
      
   end
end
