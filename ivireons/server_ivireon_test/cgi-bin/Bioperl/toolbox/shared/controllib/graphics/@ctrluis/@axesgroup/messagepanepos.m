function messagepanepos(this)
% messagepanepos  Positions the message pane for the axesgroup.

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:33 $

%Revisit
if ~isempty(this.MessagePane); %this.MessagePaneVisible
    % Extents of the axesgroup
    OuterPos = getOuterPosition(this);
    InnerPos = getInnerPosition(this);
    
    % Position Message Pane with respect to outer position
    % Revisit(CB) Should we display message panel if plot is to small?
    
    % Approx conversion of 12 point font to pixels (12pt~=16pixels) to normalized
    tmp = hgconvertunits(this.Parent,[16,16,16,16], ...
                'Pixels','Normalized',this.Parent);  
    MH = tmp(4)*3*1.4; % Set height to be approximately three lines if possible
    Mx = max(0,OuterPos(1)); % Make sure Mx >= 0
    My = min(OuterPos(2)+OuterPos(4),1)-MH;  % Make sure My+MH <= 1
    MW = InnerPos(1)-Mx+InnerPos(3);
    
    MessagePanePos = [Mx,My,MW,MH];
    this.MessagePane.setPosition(MessagePanePos);  
end