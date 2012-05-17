function schema
%SCHEMA  Defines properties specific to @ltisource class (LTI model)

%  Author(s): Bora Eryilmaz
%  Revised:   Kamesh Subbarao
%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:48 $

% Find parent package
pkg = findpackage('resppack');

% Register class 
c = schema.class(pkg, 'ltisource', findclass(pkg, 'respsource'));

% Class attributes
p = schema.prop(c, 'Model',    'MATLAB array');     % LTI model(s)
p.SetFunction = @LocalSetModel;

p = schema.prop(c, 'UncertainModel', 'MATLAB array');

schema.prop(c, 'Cache', 'MATLAB array'); % Time resp. info (struct)
% Cache = struct array w/ fields Stable,MStable,DCGain,Margins

%%%%%%%%%%%%%%%%%%%%%%
% LOCALSETFUNCTION
%%%%%%%%%%%%%%%%%%%%%%
function sys = LocalSetModel(this, sys)
% For idmodels, appropriate conversion is made and set in the Model
% property
if ~isa(sys,'lti')
    % Must comes from IDENT at this point
    % Check the number of inputs to the model
    nu = size(sys,'nu');
    if nu > 0
        % If the model is not a time series or output spectrum extract the
        % model from the input channels to output channels.
        sys = sys('m');
    elseif nu==0 && isa(sys,'idfrd')
        % If the model is an output spectrum model error out.
        ctrlMsgUtils.error('Controllib:plots:LTISource1')
    else
        % If the model is a time series idmodel extract the model from the 
        % noise channels to output channels 
        sys = sys('n');
    end
    % Perform the conversion of the IDENT models to LTI Models
    if isa(sys,'idss')
        sys = ss(sys);
    elseif isa(sys,'idfrd')
        sys = frd(sys);
    else
        sys = tf(sys);
    end
end
