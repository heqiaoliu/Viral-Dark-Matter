function S = getNlhwNonlinTypes(var,id)
%return cell array of valid nonlin types for idnlhw
% var: 'id'(default) or 'name'
% If id is provided, return name for the corresponding id, rather than the
% whole list

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:50:21 $
% Written by Rajiv Singh.

if nargin<2
    if strcmpi(var,'name')
        S = {'Piecewise Linear', 'Sigmoid Network','Saturation','Dead Zone',...
            'Wavelet Network','One-dimensional Polynomial','None'};
    elseif strcmpi(var,'id')
        S = {'pwlinear','sigmoidnet','saturation','deadzone','wavenet','poly1d','none'};
    end
else
    switch lower(id)
        case 'wavenet'
            S = 'Wavelet Network';
        case 'saturation'
            S = 'Saturation';
        case 'deadzone'
            S = 'Dead Zone';
        case 'pwlinear'
            S = 'Piecewise Linear';
        case {'sigmoid','sigmoidnet'}
            S = 'Sigmoid Network';
        case 'poly1d'
            S = 'One-dimensional Polynomial';
        case {'none','unitgain'}
            S = 'None';
        otherwise
            ctrlMsgUtils.error('Ident:idguis:invalidNonlinType',lower(id))
    end
end
