function layout(this)
%function layout(this)
%
%Layout method for @OkCancelHelpApply class

% Author(s): Alec Stothert
% Revised:
% Copyright 1986-2004 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:24 $

% New width and height
this.Width = 4*this.bWidth+3*this.bgap;
this.Height = this.bHeight;
   
% Position the buttons
X0 = 0; Y0 = 0;
set(this.hOK, 'Position',[X0 Y0 this.bWidth this.bHeight]);
X0 = X0+this.bWidth+this.bgap;
set(this.hCancel, 'Position',[X0 Y0 this.bWidth this.bHeight]);
X0 = X0+this.bWidth+this.bgap;
set(this.hHelp, 'Position',[X0 Y0 this.bWidth this.bHeight]);
X0 = X0+this.bWidth+this.bgap;
set(this.hApply, 'Position',[X0 Y0 this.bWidth this.bHeight]);
% Position container
set(this.hC,'Position',[this.X0, this.Y0, this.Width, this.Height]);
