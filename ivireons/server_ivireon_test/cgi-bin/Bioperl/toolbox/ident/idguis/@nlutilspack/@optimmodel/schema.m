function schema
%SCHEMA  Define properties for @optimmodel class.
% optimmodel facilitates optimization related to operating point and state
% vector search. 
%
% Known subclasses: idnlarxopmodel, idnlarxstatemodel, idnlhwopmodel,
% idnlhwstatemodel.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:33 $

c = schema.class(findpackage('nlutilspack'),'optimmodel');

% store (nonlinear) model
schema.prop(c,'Model','MATLAB array');

% Algorithm
schema.prop(c,'Algorithm','MATLAB array');

% Version
p = schema.prop(c,'Version','MATLAB array');
p.AccessFlags.PublicSet = 'off';

% Type of optimization: for equilibrium point ('op') or for states
% ('state')
schema.prop(c,'Type','string');
p.FactoryValue = 'op';
