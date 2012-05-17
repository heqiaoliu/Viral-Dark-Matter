function [WS, WSname] = findParametersWS(this, model, names) %#ok<INUSL>
% Finds in what workspace (model vs. base) parameters should be resolved.
%
% [WS, WSname] = findParametersWS(this, model, names)
%
% WS - cell array with type of workspace where parameter is found
% WSname - name of workspace where parameter is found

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/05/20 03:06:14 $

%Pre allocate variables
WS     = cell(size(names));
WSname = WS;

%Strip out any names indexing
names  = strtok(names, '.({');

for ct = 1:numel(names)
    try
        ctx = slResolve(names{ct}, model, 'context');
                
        if strcmp(ctx, 'Model')
            wksName = model;
            wksType = 'model';
        elseif strcmp(ctx, 'Global')
            wksName = 'base workspace';
            wksType = 'base';    
        else
            % Error, some new type of workspace
            error('unsupported workspace');
        end
        
        WS{ct}     = wksType;
        WSname{ct} = wksName;
    catch
        ctrlMsgUtils.error( 'SLControllib:slcontrol:ParameterNotFound', names{ct} )
    end        
end

end

