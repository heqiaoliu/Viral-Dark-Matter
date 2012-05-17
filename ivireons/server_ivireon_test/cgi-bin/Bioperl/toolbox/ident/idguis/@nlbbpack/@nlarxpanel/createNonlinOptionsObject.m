function h = createNonlinOptionsObject(this,jh,Name)
%create nonlinearity options objects of type specified by
%string Name.
% jh: java handle to the model properties panel of the current type (Name).
% Name must be one of:
%  'wavenet', 'tree', 'sigmoid', 'neuralnet', 'customnet',
%  'linear' ('none').

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:12:46 $

%h = [];
switch Name
    case 'tree'
        h = nloptionspack.treeoptions(this,jh);
    case 'wavenet'
        h = nloptionspack.wavenetoptions(this,jh);
    case 'sigmoid'
        h = nloptionspack.sigmoidnetoptions(this,jh);
    case 'neuralnet'
        h = nloptionspack.mlnetoptions(this,jh);
    case {'custom','customnet'}
        h = nloptionspack.customnetoptions(this,jh);
    case {'linear','none'}
        h = nloptionspack.linearoptions(this,jh);
    otherwise
        ctrlMsgUtils.error('Ident:idguis:invalidNonlinType',Name)
end
