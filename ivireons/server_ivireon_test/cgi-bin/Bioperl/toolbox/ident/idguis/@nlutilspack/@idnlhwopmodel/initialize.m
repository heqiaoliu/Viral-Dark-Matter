function initialize(this)
%initialize object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:19 $

model = this.Model;
[ny,nu] = size(model);
this.Algorithm = model.Algorithm;

op = this.OperPoint;
u0 = op.Input;
y0 = op.Output;
this.Data.nufree = sum(~u0.Known);
this.Data.nyfree = sum(~y0.Known);

[A,B,C,D] = ssdata(model.LinearModel);
this.Data.A = A;
this.Data.B = B;
this.Data.C = C;
this.Data.D = D;
Nx = size(A,1);
this.Data.Nx = Nx;
AIB = pinv(eye(Nx)-A)*B;
this.Data.AIB = AIB;
this.Data.TFun = C*AIB + D;
