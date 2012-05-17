function initialize(this)
%Initialize object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/03/13 17:24:12 $

model = this.Model;
%[ny,nu] = size(model);
this.Algorithm = model.Algorithm;
this.Algorithm.Criterion = 'Trace';

LinMod = getlinmod(model);
[A,B,C,D] = ssdata(LinMod);
this.Data.LinMod = LinMod;
this.Data.A = A;
this.Data.B = B;
this.Data.C = C;
this.Data.D = D;
this.Data.Nx = size(A,1);
