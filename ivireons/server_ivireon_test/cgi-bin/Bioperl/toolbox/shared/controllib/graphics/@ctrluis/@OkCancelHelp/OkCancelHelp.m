function this = OkCancelHelp(Parent,X0,Y0)
%Constructor for @OkCancelHelp class
%
%Creates a uicontainer object with three buttons, 'Ok',
%'Cancel' and 'Help'
%
%Inputs:
%     Parent:      Double, handle to figure or panel in which container
%                  is to be created.
%     X0    :      Optional, x-Coordinate of lower left corner of object in parent
%     Y0    :      Optional, y-Coordinate of lower left corner of obejct in parent
%
%Outputs:
%     this:       Created object.

% Author(s): Alec Stothert
% Revised:
% Copyright 1986-2004 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:18 $

if nargin == 0
  % Call when reloading object
  this = ctrluis.OkCancelHelp;
  return
end

%Create default object
this = ctrluis.OkCancelHelp;

%Process position input arguments
switch nargin
    case 2
        this.X0 = X0;
    case 3
        this.X0 = X0;
        this.Y0 = Y0;
end

%Build the object and lay it out
build(this,Parent);
layout(this)


