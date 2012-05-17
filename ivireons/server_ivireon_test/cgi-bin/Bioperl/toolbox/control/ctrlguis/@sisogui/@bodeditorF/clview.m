function Views = clview(this,LoopData,Request)
% Provides available closed-loop views for a given configuration.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2006/03/26 01:11:24 $
Views = struct('Description',[],'Input',[],'Output',[]);
% RE: Input and Output are scalar indices relative to LoopData.ClosedLoop
%     that define the closed-loop transfer function shown in the editor

% vector (output,input);
ClosedLoopIO = LoopData.L(this.EditedLoop).ClosedLoopIO;
Output = ClosedLoopIO(1);
Input = ClosedLoopIO(2);


Views.Description = sprintf('Closed-loop response from %s to %s.',...
    LoopData.Input{Input},LoopData.Output{Output});
Views.Input = Input;
Views.Output = Output;
      
  

if strcmp(Request,'default')
   % Default closed-loop view
   Views = Views(1);
end
