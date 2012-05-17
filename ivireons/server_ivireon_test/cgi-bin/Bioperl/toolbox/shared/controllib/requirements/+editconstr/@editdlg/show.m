function show(h,Constr)
%SHOW  Brings up and points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Revised: A. Stothert, converted to MJcomponents
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:06 $

% RE: h = @editdlg handle

% Initialize dialog when first used
if isempty(h.Handles)
    % Create dialog
    h.Handles = h.build;
    % Listener to targeted constraint
    addlistener(h, 'Constraint', 'PostSet',@h.cbConstraintChanged);
end

% Set target (edited constraint)
h.target(Constr);

% Make frame visible
Frame = h.Handles.Frame;

% Used to force the dialog to spawn on top of the figure, see g242840
drawnow expose

if Frame.isVisible
  % Raise window
  awtinvoke(Frame,'toFront');
else
  % Bring it up centered
  hFig = gcbf;
  if isempty(hFig)
      centerfig(Frame)
  else
      centerfig(Frame, hFig);
  end
  awtinvoke(Frame,'setVisible(Z)',true);
  %Force parambox to update, as contents only update when visible
  h.updateParambox
end
end

