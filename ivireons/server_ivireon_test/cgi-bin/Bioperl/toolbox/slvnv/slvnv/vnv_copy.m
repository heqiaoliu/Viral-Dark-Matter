function vnv_copy(method, obj, varargin)
% VNV_COPY Correctly duplicate RMI data when copying Simulink objects

%  Copyright 1984-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.8.4.1 $  $Date: 2010/07/23 15:45:40 $

    if(~slfeature('MdlDuplicateRequirementsOnCopy'))
        return;
    end

    switch(lower(method))
    case 'objcopy'
        objCopy(obj, varargin{1:end});

    case 'chartcopy'
       try
            objCopy(obj);
            trans = sf('get',obj,'.transitions');
            if (~isempty(trans))
                for tran = trans(:)'
                    objCopy(tran);
                end
            end
            states = sf('get',obj,'.states');
            if (~isempty(states))
                for state = states(:)'
                    objCopy(state);
                end
            end
       catch Mex %#ok<NASGU>
       end
    end

function objCopy(obj, varargin)
    if ~isempty(varargin) && ischar(varargin{1}) && strcmpi(varargin{1},'disableLink')
        return;
    end

    try
        [reqStr, isSf] = getRawReqsIfNotImplicit(obj);
        if isempty(reqStr)
            return;
        end
        modelH = util_getmodelh(obj, isSf);
        rmi('objCopy', obj, reqStr, modelH, isSf);
    catch Mex %#ok<NASGU>
    end

function [result, isSf] = getRawReqsIfNotImplicit(obj)
    result = [];
    [isSf, objH, ~] = resolveobj(obj);

    if isempty(objH)
        return;
    end

    if isSf
        result = sf('get', objH, '.requirementInfo');
    else
        if ~is_an_implicit_link(objH)
            result = get_param(objH, 'requirementInfo');
        end
    end

function [isSf, objH, errMsg] = resolveobj(obj)
% TODO: this utility is duplicated under slvnv/slvnv/private and slvnv/remgt/+rmi

    isSf = false;
    objH = [];
    errMsg = '';

    className = class(obj);

    switch(className)
    case 'double'
        if (floor(obj) == obj)
            % Potential Stateflow handle
            isSf = true;
            [objH, errMsg] = is_valid_stateflow_handle(obj);
        else
            % Potential Simulink handle
            [objH, errMsg] = is_valid_simulink_handle(obj);
        end

    case {'Simulink.BlockDiagram', 'Simulink.Block'}
        objH = obj.handle;


    case {'Stateflow.Chart',     'Stateflow.State', ...
          'Stateflow.Box',       'Stateflow.EMFunction', ...
          'Stateflow.Transition','Stateflow.TruthTable', ...
          'Stateflow.Function', 'Stateflow.SLFunction', ...
          'Stateflow.AtomicSubchart'}
        isSf = true;
        objH = obj.Id;

    case 'char'
        try
            objH = get_param(obj,'Handle');
        catch Mex %#ok<NASGU>
            errMsg = ['Invalid Simulink path: ' obj];
        end

        if ~isempty(errMsg)
            [objH, errMsg] = is_valid_simulink_handle(objH);
        end


    otherwise
        if isa(obj,'Simulink.Block')
            objH = obj.handle;
        else
            errMsg = ['Class ' className ' is not valid for a requirement object'];
        end
    end



function [objH, errMsg] = is_valid_simulink_handle(obj)
    errMsg = '';
    objH = [];

    if ~ishandle(obj)
        errMsg = ['Invalid object handle: ' num2str(obj)];
        return;
    end

    try
        slType = get_param(obj,'type');
        switch (slType)
        case {'block','block_diagram'}
            objH = obj;
        otherwise
            errMsg = ['Simulink ' slType ' objects do not support requirements'];
        end
    catch Mex %#ok<NASGU>
        errMsg = ['Expected a Simulink handle: ' num2str(obj)];
    end



function [objH, errMsg] = is_valid_stateflow_handle(obj)
    errMsg = '';
    objH = [];
    sfisa = vnv_sfisa;

    if sf('ishandle',obj)
        objsSfIsa = sf('get',obj,'.isa');
        for objSfIsa = objsSfIsa(:)'
            switch(objSfIsa)
            case {sfisa.chart, sfisa.state, sfisa.transition}
                objH = obj;
            otherwise
                errMsg = 'Stateflow object type does not support requirements';
            end
        end
    else
        errMsg = ['Invalid object handle: ' num2str(obj)];
    end

function isImplicit = is_an_implicit_link(blockH)
%%%% IMPORTANT: this is a safe/lightweight way of
%%%% figuring out if a link is an implicit link
parentH = get_param(get_param(blockH,'parent'),'handle');
if(~strcmp(get_param(parentH,'type'),'block_diagram') && ...
        (~isempty(get_param(parentH,'referenceblock')) || ~isempty(get_param(parentH,'templateblock'))))
    isImplicit = true;
else
    isImplicit = false;
end


function sfisa = vnv_sfisa

    persistent sfIsaStruct;

    if isempty(sfIsaStruct)
        sfIsaStruct.chart = sf('get', 'default', 'chart.isa');
        sfIsaStruct.state = sf('get', 'default', 'state.isa');
        sfIsaStruct.junction = sf('get', 'default', 'junction.isa');
        sfIsaStruct.transition = sf('get', 'default', 'transition.isa');
        sfIsaStruct.machine = sf('get', 'default', 'machine.isa');
        sfIsaStruct.target = sf('get', 'default', 'target.isa');
        sfIsaStruct.event = sf('get', 'default', 'event.isa');
        sfIsaStruct.data = sf('get', 'default', 'data.isa');
        sfIsaStruct.instance = sf('get', 'default', 'instance.isa');
    end

    sfisa = sfIsaStruct;



