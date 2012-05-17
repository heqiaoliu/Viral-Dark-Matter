function this = bodeditorF(LoopData,idxL)
%BODEDITORF  Constructs Bode Editor for feedforward compensators

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.10.4.5 $ $Date: 2010/04/11 20:30:02 $
if LoopData.L(idxL).Feedback
   ctrlMsgUtils.error('Control:compDesignTask:grapheditor1')
end
this = sisogui.bodeditorF;

% Initialize properties 
this.LoopData = LoopData;
this.EditedLoop = idxL;

% Initialize compensator targets
this.initializeCompTarget;

% Default closed-loop view
DefaultView = this.clview(LoopData,'default');
this.ClosedLoopView = DefaultView;

% Initialize uncertain bounds class
this.UncertainBounds = sisogui.BodeUncertain(this);


