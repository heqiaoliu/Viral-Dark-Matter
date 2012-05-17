function schema
%SCHEMA  Define properties for @idnlarxopmodel class.
% idnlarxopmodel facilitates optimization related to operating point and
% state vector search for idnlarx models; subclass of optimmodel class

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:08 $

pkg = findpackage('nlutilspack');
parent = findclass(pkg,'optimmodel');
c = schema.class(pkg,'idnlarxopmodel',parent);

% store parameter info; use operating point object 
schema.prop(c,'OperPoint','MATLAB array');

% Data
p = schema.prop(c,'Data','MATLAB array');
p.FactoryValue = struct('nufree',[],'nyfree',[],'Delays',[],...
    'CumInd',[],'Nx',[]);