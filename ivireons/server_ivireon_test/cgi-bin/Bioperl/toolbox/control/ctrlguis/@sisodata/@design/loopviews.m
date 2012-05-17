function LoopTF = loopviews(this,Configuration)
% Updates list of viewable loop transfer functions for each built-in configuration.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2006/06/20 20:01:18 $

% UDDREVISIT: private static
inames = this.Input;
onames = this.Output;

switch Configuration
   case {1,2,3,4}
      % Single-loop configurations
      for ct=10:-1:1
         LoopTF(ct,1) = sisodata.looptransfer;
      end
      % Closed-loop responses
      LoopTF(1).Type = 'T';
      LoopTF(1).Index = {1 1};
      LoopTF(1).Description = sprintf('Closed Loop %s to %s',inames{1},onames{1}); % r to y
      LoopTF(1).ExportAs = 'T_r2y';
      LoopTF(1).Style = 'b';
      LoopTF(2).Type = 'T';
      LoopTF(2).Index = {2 1};
      LoopTF(2).Description = sprintf('Closed Loop %s to %s',inames{1},onames{2}); % r to u
      LoopTF(2).ExportAs = 'T_r2u';
      LoopTF(2).Style = 'g';
      LoopTF(3).Type = 'T';
      LoopTF(3).Index = {1 3};
      LoopTF(3).Description = xlate('Input Sensitivity ');
      LoopTF(3).ExportAs = 'S_in';
      LoopTF(3).Style = 'r';
      LoopTF(4).Type = 'T';
      LoopTF(4).Index = {1 2};
      LoopTF(4).Description = xlate('Output Sensitivity');
      LoopTF(4).ExportAs = 'S_out';
      LoopTF(4).Style = 'c';
      LoopTF(5).Type = 'T';
      LoopTF(5).Index = {1 4};
      LoopTF(5).Description = xlate('Noise Sensitivity');
      LoopTF(5).ExportAs = 'S_noise';
      LoopTF(5).Style = 'm';
      % Open-loop responses
      LoopTF(6).Type = 'L';
      LoopTF(6).Index = 1;
      LoopTF(6).Description = xlate('Open Loop L');
      LoopTF(6).ExportAs = 'L';
      LoopTF(6).Style = 'y';
      LoopTF(7).Type = 'C';
      LoopTF(7).Index = 1;
      LoopTF(7).Style = 'r--';
      LoopTF(8).Type = 'C';
      LoopTF(8).Index = 2;
      switch Configuration
         case {1 2}
            LoopTF(7).Description = xlate('Compensator C');
            LoopTF(8).Description = xlate('Prefilter F');
         case 3
            LoopTF(7).Description = xlate('Compensator C');
            LoopTF(8).Description = xlate('Feedforward F');
         case 4
            LoopTF(7).Description = xlate('Primary Compensator C1');
            LoopTF(8).Description = xlate('Minor-Loop Compensator C2');
      end
      LoopTF(8).Style = 'g--';
      LoopTF(9).Type = 'G';
      LoopTF(9).Index = 1;
      LoopTF(9).Description = xlate('Plant G');
      LoopTF(9).Style = 'b--';
      LoopTF(10).Type = 'G';
      LoopTF(10).Index = 2;
      LoopTF(10).Description = xlate('Sensor H');
      LoopTF(10).Style = 'm--';
      
    case 5
      for ct=8:-1:1
         LoopTF(ct,1) = sisodata.looptransfer;
      end
      LoopTF(1).Type = 'T';
      LoopTF(1).Index = {1 1};
      LoopTF(1).Description = sprintf('Closed Loop %s to %s',inames{1},onames{1}); % r to y
      LoopTF(1).ExportAs = 'T_r2y';
      LoopTF(1).Style = 'b';
      
      LoopTF(2).Type = 'T';
      LoopTF(2).Index = {2 1};
      LoopTF(2).Description = sprintf('Closed Loop %s to %s',inames{1},onames{2}); % r to u
      LoopTF(2).ExportAs = 'T_r2u';
      LoopTF(2).Style = 'g';
      
      LoopTF(3).Type = 'L';
      LoopTF(3).Index = 1;
      LoopTF(3).Description = xlate('Open Loop L');
      LoopTF(3).ExportAs = 'L';
      LoopTF(3).Style = 'r';
      
      LoopTF(4).Type = 'C';
      LoopTF(4).Index = 1;
      LoopTF(4).Description = xlate('Compensator C');
      LoopTF(4).Style = 'c';
      
      LoopTF(5).Type = 'C';
      LoopTF(5).Index = 2;
      LoopTF(5).Description = xlate('Prefilter F');
      LoopTF(5).Style = 'm';
      
      LoopTF(6).Type = 'G';
      LoopTF(6).Index = 1;
      LoopTF(6).Description = xlate('Plant G1');
      LoopTF(6).Style = 'y';
      
      LoopTF(7).Type = 'G';
      LoopTF(7).Index = 2;
      LoopTF(7).Description = xlate('Estimated Plant G2');
      LoopTF(7).Style = 'b--';
      
      LoopTF(8).Type = 'G';
      LoopTF(8).Index = 3;
      LoopTF(8).Description = xlate('Disturbance Model Gd');
      LoopTF(8).Style = 'g--';

    
    case 6
      for ct=10:-1:1
          LoopTF(ct,1) = sisodata.looptransfer;
      end
      LoopTF(1).Type = 'T';
      LoopTF(1).Index = {4 1};
      LoopTF(1).Description = sprintf('Closed Loop %s to %s',inames{1},onames{4}); % r to y
      LoopTF(1).ExportAs = 'T_r12y1';
      LoopTF(1).Style = 'b';
      
      LoopTF(2).Type = 'T';
      LoopTF(2).Index = {2 1};
      LoopTF(2).Description = sprintf('Closed Loop %s to %s',inames{1},onames{3}); % r to u
      LoopTF(2).ExportAs = 'T_r12u2';
      LoopTF(2).Style = 'g';
      
      LoopTF(3).Type = 'L';
      LoopTF(3).Index = 1;
      LoopTF(3).Description = sprintf('Open Loop - Output of %s', 'C1');
      LoopTF(3).ExportAs = 'L';
      LoopTF(3).Style = 'r';
      
      LoopTF(4).Type = 'L';
      LoopTF(4).Index = 2;
      LoopTF(4).Description = sprintf('Open Loop - Output of %s', 'C2');
      LoopTF(4).ExportAs = 'L';
      LoopTF(4).Style = 'c';
      
      LoopTF(5).Type = 'C';
      LoopTF(5).Index = 1;
      LoopTF(5).Description = sprintf('Compensator %s', 'C1');
      LoopTF(5).Style = 'm';
      
      LoopTF(6).Type = 'C';
      LoopTF(6).Index = 2;
      LoopTF(6).Description = sprintf('Compensator %s', 'C2');
      LoopTF(6).Style = 'y';
      
      LoopTF(7).Type = 'C';
      LoopTF(7).Index = 3;
      LoopTF(7).Description = xlate('Prefilter F');
      LoopTF(7).Style = 'b--';
      
      LoopTF(7).Type = 'G';
      LoopTF(7).Index = 1;
      LoopTF(7).Description = sprintf('Plant %s', 'G1');
      LoopTF(7).Style = 'g--';
      
      LoopTF(8).Type = 'G';
      LoopTF(8).Index = 2;
      LoopTF(8).Description = sprintf('Plant %s', 'G2');
      LoopTF(8).Style = 'r--';
      
      LoopTF(9).Type = 'G';
      LoopTF(9).Index = 3;
      LoopTF(9).Description = sprintf('Sensor %s', 'H1');
      LoopTF(9).Style = 'c--';
      
      LoopTF(10).Type = 'G';
      LoopTF(10).Index = 4;
      LoopTF(10).Description = sprintf('Sensor %s', 'H2');
      LoopTF(10).Style = 'm--';


end
