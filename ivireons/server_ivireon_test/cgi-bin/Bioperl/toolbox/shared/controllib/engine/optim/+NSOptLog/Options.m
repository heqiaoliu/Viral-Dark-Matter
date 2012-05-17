classdef (Hidden) Options
% Display and instrumentation options.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:36:58 $
properties
      % Display Level (0=silent,1=final,2=iter)
      Verbosity = 0;
      % Debugging model
      Debug = false;
      % Graphical display
      Graphics;
      % Data Logging
      DataLog;
   end
   
   methods
      
      function this = Options()
         % Graphical output
         %   ShowSV: Plot singular values at each iteration
         this.Graphics = struct(...
            'ShowSV',false);
         % Data Logging
         this.DataLog = struct(...
            'Progress',false);   % Log objective and constraint values
      end
      
   end
      
end


