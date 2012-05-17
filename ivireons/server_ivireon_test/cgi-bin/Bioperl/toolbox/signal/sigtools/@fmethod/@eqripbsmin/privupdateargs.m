function args = privupdateargs(this,args,Nstep)
%PRIVUPDATEARGS Utility fcn called by POSTPROCESSMINORDERARGS

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/04 23:24:24 $

% Increase order
args{1} = args{1}+Nstep;
if rem(args{1},2),
    % Force even order
    args{1} = args{1} + 1;
end

devs = args{4};                             % Deviations
if ~any(devs==1),
    % Convert Deviations to Weights
    args{4} = ones(size(devs))*max(devs)./devs; % Normalized weights
end
