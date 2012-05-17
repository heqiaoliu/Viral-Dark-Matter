function schema
%SCHEMA  Define properties for @idnlhwstatemodel class.
% idnlhwstatemodel facilitates optimization related to state vector search
% for idnlhw models; subclass of optimmodel class 

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:28 $

pkg = findpackage('nlutilspack');
parent = findclass(pkg,'optimmodel');
c = schema.class(pkg,'idnlhwstatemodel',parent);

% Data
p = schema.prop(c,'Data','MATLAB array');
p.FactoryValue = struct('LinMod',[],'Nx',[],...
    'A',[],'B',[],'C',[],'D',[],'X0guess',[]);
