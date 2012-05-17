function setEditedBlock(this,C)
% Sets target block to C and recomputes normalized information

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/06/20 20:02:29 $

if ~(C == this.EditedBlock); 
    % Renormalize editors frequency repsonse with respect to new target
    
    % Re-Normalization factor 
    GainC = getZPKGain(C);
    if isequal(GainC,0);
        % Protect against GainC = 0 (not sure if this condition is possible
        % though)
        GainC = 1; 
    end
    
    % Update Magnitude data of editor
    GainFactor = getZPKGain(this.EditedBlock)/GainC;
    this.Magnitude = GainFactor * this.Magnitude;
    
    % Set Edited Block to the compensator being edited
    this.EditedBlock = C;
end