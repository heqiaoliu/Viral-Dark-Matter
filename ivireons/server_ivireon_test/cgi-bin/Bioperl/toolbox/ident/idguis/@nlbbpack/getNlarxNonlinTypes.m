function S = getNlarxNonlinTypes(var,id)
%return cell array of valid model types
% var: 'id'(default) or 'name'
% If id is provided, return name for the corresponding id, rather than the
% whole list.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:50:20 $

if nargin<2
    if strcmpi(var,'name')
        S = {'Wavelet Network','Tree Partition','Sigmoid Network',...
            'Neural Network','Custom Network','None'};
    elseif strcmpi(var,'id')
        S = {'wavenet','tree','sigmoid','neuralnet','custom','linear'};
    end
else
    switch lower(id)
        case 'wavenet'
            S = 'Wavelet Network';
        case {'tree','treepartition'}
            S = 'Tree Partition';
        case {'sigmoid','sigmoidnet'}
            S = 'Sigmoid Network';
        case 'neuralnet'
            S = 'Neural Network';
        case {'custom','customnet'}
            S = 'Custom Network';
        case {'linear','none'}
            S = 'None';
        otherwise
            ctrlMsgUtils.error('Ident:idguis:invalidNonlinType',lower(id))
    end
end
