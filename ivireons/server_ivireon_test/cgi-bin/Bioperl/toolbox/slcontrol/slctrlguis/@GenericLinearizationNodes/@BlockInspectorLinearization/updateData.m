function updateData(this,J) 
% GETABCD - Get the state matrices of a linearization

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2009/03/31 00:22:52 $

% Allow the inspector data to be updated.
this.A = full(J.A(this.indx,this.indx));
this.B = full(J.B(this.indx,this.indu));
this.C = full(J.C(this.indy,this.indx));
this.D = full(J.D(this.indy,this.indu));
if ~isempty(this.indy) && ~isempty(this.indu) && ...
        J.Mi.BlocksInPath(J.Mi.OutputInfo(this.indy(1),1)== J.Mi.BlockHandles);
    this.InLinearizationPath = 'Yes';
else
    this.InLinearizationPath = 'No';
end