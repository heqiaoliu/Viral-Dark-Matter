function this = OkCancelHelpApply(Parent,X0,Y0)
%Constructor for @OkCancelHelpApply class
%
%Creates a uicontainer object with four buttons, 'Ok',
%'Cancel', 'Help' and 'Apply'. Inherits from @OkCancelHelp class
%
%Inputs:
%     Parent:      Double, handle to figure or panel in which container
%                  is to be created.
%     X0    :      x-Coordinate of lower left corner of object in parent
%     Y0    :      y-Coordinate of lower left corner of obejct in parent
%
%Outputs:
%     this:       Created object.

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:23 $

if nargin == 0
  % Call when reloading object
  this = ctrluis.OkCancelHelpApply;
  return
end

%Create default object
this = ctrluis.OkCancelHelpApply;

%Process position input arguments
switch nargin
    case 2
        this.X0 = X0;
    case 3
        this.X0 = X0;
        this.Y0 = Y0;
end

%Build the object and lay it out
localbuild(this,Parent);
layout(this)

%-------------------------------------------------------------------------%
%
%Function to construct container with Ok, Help and Cancel buttons.
function localbuild(this,Parent)

%Use build method from parent
build(this,Parent);
%Add the apply button and resize the container
this.hApply = uicontrol('Parent',this.hC, ...
    'Style','pushbutton',...
    'Units','characters', ...
    'Callback','', ...
    'String', sprintf('Apply'), ...
    'Tag', 'btnApply');
this.Width = this.Width + this.bgap + this.bWidth;

