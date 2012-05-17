function data = utValidateData(data, model, domain, multiExpTs, command)
%UTVALIDATEDATA checks data for suitability of use with given "command".
% data: iddata or double matrix
% model: idmodel/idnlmodel; use [] to avoid model-based checks
% domain: 'time', 'frequency', 'both'
% multiExpTs: true/false; indicates is Ts values must match in multi-exp
%             data
% command: name of command for which this validation is being performed.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/04/21 03:22:58 $

% Attributes checked:
% 1. I/O dimension and Ts compatibility between model and data.
% 2. Irregularly sampled data.
% 3. Data domain applicability (time, freq, both).
% 4. Multi-exp Ts uniformity. 
% 5. Missing samples
% Note: double data fails the test unless model is also supplied.


if ~isfloat(model)
    [ny, nu] = size(model);
    Ts = pvget(model,'Ts');
else
    ny = 0; nu = 0;
    Ts = 1;
end

command = lower(command);
domain = lower(domain);

if isa(data,'iddata')
    s = size(data);
    if ~isfloat(model)
        % model-data comparison only if model ~= []
        if ~isequal([ny,nu],s(2:3))
            ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
        end
    end

    Tsdat = pvget(data,'Ts');
    if  any(cellfun('isempty',Tsdat))
        ctrlMsgUtils.error('Ident:iddata:wrongDataTs',command)
    end

    if ~strcmpi(domain,'both') && ~strcmpi(domain,data.Domain)
        ctrlMsgUtils.error('Ident:iddata:incorrectDataDomain',command,domain)
    end
     
    if multiExpTs && length(Tsdat)>1 && any(cellfun(@(x)(x-Tsdat{1})>10*eps,Tsdat))
        % sample time uniformity is not required for data analysis or
        % processing
        ctrlMsgUtils.error('Ident:iddata:multiExpDataTsMismatch',command)
    elseif isnan(data)
        ctrlMsgUtils.error('Ident:utility:missingData',command)
    end
    
    if ~isfloat(model) && abs(Tsdat{1}-Ts)>10*eps && Ts>0
        ctrlMsgUtils.warning('Ident:iddata:dataModelTsMismatch')
        Tsdat{1} = Ts;
        data = pvset(data,'Ts',Tsdat);
    end

elseif isa(data,'double') && ndims(data)==2 && ~isfloat(model)
    % accept double data if there is a model context
    
    if ~isequal(ny+nu,size(data,2))
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
    data = iddata(data(:,1:ny),data(:,ny+1:ny+nu),Ts);
else
    ctrlMsgUtils.error('Ident:iddata:unrecognizedData',command)
end
