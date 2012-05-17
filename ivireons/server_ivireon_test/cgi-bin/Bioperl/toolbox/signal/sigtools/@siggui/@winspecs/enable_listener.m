function enable_listener(this, varargin)
%ENABLE_LISTENER Overload the siggui superclass's enable listener

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2008/08/22 20:33:27 $

enabState = get(this, 'Enable');

if strcmpi(enabState, 'Off')
    siggui_enable_listener(this, varargin{:})
else

    window = get(this, 'Window');

    h = get(this, 'Handles');
    
    setenableprop([h.winname_lbl h.winname h.type_lbl h.type], 'On');

    if isa(window, 'sigwin.userdefined')
        enab = 'On';
    else
        enab = 'Off';
    end

    setenableprop([h.matlabexpression h.matlabexpression_lbl], enab);

    if isa(window, 'sigwin.variablelength')
        style = 'edit';
    else
        style = 'text';
    end

    set(h.length, 'style', style);
    setenableprop([h.length_lbl h.length], 'On');

    lbl = getparameter(this);
    if isempty(lbl)
        lbl  = {'Parameter' 'Parameter2'};
        str  = {'' ''};
        enab = {'Off' 'Off'};
    else
        paramstruct = get(this, 'Parameters');
        str  = {paramstruct.(lbl{1}) ''};
        enab = {'On' 'Off'};
        if ~isempty(lbl{2})
            str{2}  = paramstruct.(lbl{2});
            enab{2} = 'On';
        else
            lbl{2}='Parameter2';
        end
    end

    set(h.parameter_lbl, 'String', sprintf('%s:', lbl{1}));
    set(h.parameter,     'String', str{1});
    setenableprop([h.parameter_lbl h.parameter], enab{1});
    set(h.parameter2_lbl, 'String', sprintf('%s:', lbl{2}));
    set(h.parameter2,     'String', str{2});
    setenableprop([h.parameter2_lbl h.parameter2], enab{2});
    
    if isa(window, 'sigwin.samplingflagwin')
        enab = 'On';
    else
        enab = 'Off';
    end

    setenableprop([h.samplingflag h.samplingflag_lbl], enab);

    [classnames, winnames] = findallwinclasses;
    winnames(end) = [];
    indx = find(strcmpi(get(classhandle(window), 'Name'), classnames));
    set(h.type, 'Value', indx);
end

% [EOF]
