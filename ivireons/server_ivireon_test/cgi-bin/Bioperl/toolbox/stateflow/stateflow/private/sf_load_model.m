function sf_load_model(modelName)
%
% Silently loads a Simulink model given its name.
%

%   Jay Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2008/12/01 08:07:22 $

	eval([modelName,'([],[],[],''load'');'], ''); %#ok<EVLC>

