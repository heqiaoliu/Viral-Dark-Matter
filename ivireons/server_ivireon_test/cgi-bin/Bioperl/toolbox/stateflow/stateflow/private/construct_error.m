function varargout = construct_error( ids, errorType, errorMsg, throwFlag, openFcn)
%CONSTRUCT_ERROR(IDS,ERRORTYPE,ERRORMSG,THROWFLAG)  
%Centralized error message generation function for SF.
%All SF modules must call construct_error instead of error() directly.
%IDS must be an array of data-dictionary ids relevant to the error
%message. IDS can be an empty vector.
%ERRORTYPE is a string that represents the module generating the error
%examples of ERRORTYPE = 'Coder','Parser','Make','Runtime'
%ERRORMSG is the raw error message.
%THROWFLAG = 0 merely returns the constructed error message as an output
%THROWFLAG = 1 constructs the message and calls error() with it.


%   Vladimir Kolesnikov
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.18.2.15 $  $Date: 2008/12/01 08:05:23 $

    SLSFERRORCODE = slsfnagctlr('NagToken');

    if nargin < 5,  openFcn = []; end
    if nargin < 4,  throwFlag = 1; end
    if nargin < 3 || isempty(errorMsg),     errorMsg  = 'unknown error'; end
    if nargin < 2 || isempty( errorType ),  errorType = 'general';       end
    if nargin < 1,  ids = []; end

    if ~isempty(ids)
        id = ids(1);
    else
        id = [];
    end

    nag             = slsfnagctlr('NagTemplate');
    if throwFlag<=-2
       nag.type        = 'Warning';
    else
       nag.type        = 'Error';
    end
    % call xlate for translation purpose.
    nag.msg.details = xlate(errorMsg);
    nag.msg.type    = errorType;
    nag.msg.summary = xlate(errorMsg);
    
    nag = set_nag_component_and_names_from_id(id, nag);
    
    nag.sourceHId   = id;
    nag.ids         = ids;
    if ~isempty(openFcn)
        nag.openFcn = openFcn;
    end

    if throwFlag ~= -1,
        
        %
        % insure nice formating of displayed text by truncating the summary rows to maxWidth
        %
        maxWidth = 60;
        len = length(nag.msg.summary);
        if len >= maxWidth
            crnl = find(nag.msg.summary==10 | nag.msg.summary==13);
          
            if isempty(crnl)
                summary = [nag.msg.summary(1:maxWidth),'...'];
            else
                ind = crnl;
                if (ind(1) ~= 1)
                    ind = [1, ind];
                end
                if (ind(end) ~= len)
                    ind = [ind, len];
                end
                summary = [];
                for i=2:length(ind),
                    ind1 = ind(i-1);
                    ind2 = ind(i);
                    w = ind2-ind1;
                   
                    if w > maxWidth
                        summary = [summary, nag.msg.summary(ind1:(ind1+maxWidth)), '...'];
                    else
                        summary = [summary, nag.msg.summary(ind1:(ind2-1))];
                    end
                end
            end
        else
            summary = nag.msg.summary;
        end
    
        if ~isempty(summary) && ~strncmpi(nag.msg.type, 'Lex', 3),
            summary(summary==10) = [];
            summary(summary==13) = [];
        end
        
        % Note: the SLSFERRORCODE token MUST come before the summary as the summary may contain multibyte chars
        % which get randomly truncated by Simulink via lasterr.  If trunctaion occurs, the token is
        % munged and the NAG-Controller can't resolve the error message.    
        displayTxt = ['-->',nag.component,' ',nag.msg.type,' ',nag.type,' :',SLSFERRORCODE, summary];   
    else
        displayTxt = ['-->',nag.component,' ',nag.msg.type,' ',nag.type,' :', nag.msg.summary];
    end

    if throwFlag ~= -3
        slsfnagctlr('Naglog', 'push', nag);        
    end

    % Throw error if requested
    switch (throwFlag),
    case 1,
        slsfnagctlr('ViewNaglog'); 
        error('Stateflow:Error','%s',errorMsg); % throw the error
    case 0,
        lasterr(clean_error_msg(errorMsg));
    case -1,
      %%% this is needed so that we dont pollute lasterr when we are merely
      %%% using this function to construct a message in our format.
    case -2,
        lastwarn(displayTxt)
    case -3,
        slsfnagctlr('Naglog', 'pop', nag);
        last = lastwarn;
        if strcmp(last, displayTxt)
            lastwarn('');
        end
    end

    varargout{1} = displayTxt;

    
%-------------------------------------------------------------------------
function nag = set_nag_component_and_names_from_id(id, nag)

    nag.blkHandles = [];

    compEML = 'Embedded MATLAB';
    compTT  = 'Truth Table';
    compSF  = 'Stateflow';
    
    if is_eml_script(id)
        nag.component = compEML;
        nag.sourceName = sf('get', id, 'script.filePath');
        nag.sourceFullName = nag.sourceName;
        return;
    end
    
    idIsa = sf('get', id, '.isa');

    if isempty(idIsa)
        nag.component = compSF;
        nag.sourceName = 'Unknown';
        nag.sourceFullName = '';
        return;
    end

    MACHINE     = sf('get', 'default', 'machine.isa');
    CHART       = sf('get', 'default', 'chart.isa');
    STATE       = sf('get', 'default', 'state.isa');
    JUNCTION    = sf('get', 'default', 'junction.isa');
    TRANSITION  = sf('get', 'default', 'transition.isa');
    EVENT       = sf('get', 'default', 'event.isa');
    DATA        = sf('get', 'default', 'data.isa');
    TARGET      = sf('get', 'default', 'target.isa');
    SCRIPT      = sf('get', 'default', 'script.isa');

    chartId = [];
    isDE = false;

    switch idIsa
    case {MACHINE, TARGET, SCRIPT}
        % no chartId
    case CHART
        chartId = id;
    case {STATE, TRANSITION, JUNCTION}
        chartId = sf('get', id, '.chart');
    case {EVENT, DATA}
        isDE = true;
        parentId = sf('get', id, '.linkNode.parent');
        switch sf('get', parentId, '.isa'),
        case STATE
            chartId = sf('get', parentId, '.chart');
        case CHART
            chartId = parentId;
        end
    end

    if ~isempty(chartId)
        % chartId is now valid, so just get the instance block handle
        instanceId = sf('get', chartId, '.instance');
        nag.blkHandles = sf('get', instanceId, '.simulinkBlock');
    end

    if is_eml_chart(chartId)
        nag.component = compEML;
        if ~isDE
            % In EML block, non-DE objects are hidden
            id = chartId;
            idIsa = CHART;
        end
    elseif is_truth_table_chart(chartId)
        nag.component = compTT;
        if ~isDE
            % In TT block, non-DE objects are hidden
            id = chartId;
            idIsa = CHART;
        end
    else
        nag.component = compSF;
    end
    
    switch idIsa,
    case {MACHINE, CHART, STATE, EVENT, DATA, TARGET},
        nag.sourceName = sf('get', id, '.name');
        nag.sourceFullName = sf('FullNameOf', id, '.');
    case JUNCTION,
        nag.sourceName = ['Junct(#',int2str(id),')'];
        parentId = sf('get', id, '.linkNode.parent');
        nag.sourceFullName = [sf('FullNameOf', parentId, '.'), '.', nag.sourceName];
    case TRANSITION,
        nag.sourceName = ['Trans(#',int2str(id),')'];
        parentId = sf('get', id, '.linkNode.parent');
        nag.sourceFullName = [sf('FullNameOf', parentId, '.'), '.', nag.sourceName];
    end

