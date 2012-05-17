function schema
%SCHEMA  Define properties for @idnlarxstatemodel class.
% idnlarxstatemodel facilitates optimization related to state vector search
% for idnlarx models; subclass of optimmodel class 

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:45:53 $

pkg = findpackage('nlutilspack');
parent = findclass(pkg,'optimmodel');
c = schema.class(pkg,'idnlarxstatemodel',parent);

% Data
p = schema.prop(c,'Data','MATLAB array');
p.FactoryValue = struct('Delays',[],'Nx',[],'CumInd',[],'LenCust',[],...
    'A',[],'B',[],'StdRegGains',[],'CustRegGains',[],'X0guess',[],'Focus','p');
