function schema
%SCHEMA  Define properties for @idnlhwopmodel class.
% idnlhwopmodel facilitates optimization related to operating point and
% state vector search for idnlhw models; subclass of optimmodel class

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:21 $

pkg = findpackage('nlutilspack');
parent = findclass(pkg,'optimmodel');
c = schema.class(pkg,'idnlhwopmodel',parent);

% Store parameter info; use operating point object 
schema.prop(c,'OperPoint','MATLAB array');

% Data
p = schema.prop(c,'Data','MATLAB array');
p.FactoryValue = struct('nufree',[],'nyfree',[],'Nx',[],...
    'A',[],'B',[],'C',[],'D',[],'AIB',[],'TFun',[]);
