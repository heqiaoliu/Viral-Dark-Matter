function newdata(this)
%NEWDATA Update object based on new data to be exported.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/03/13 19:50:36 $

% If it exists, delete the contained object (this means that we are
% changing the data after creating the export object)
hlnv = getcomponent(this, 'siggui.labelsandvalues');

if ~isempty(hlnv),
    
    savenames(this);
    
    delete(hlnv);
    
    if isprop(this, 'ExportAs'),
        info = exportinfo(this.Data);
        if isfield(info, 'exportas'),
            enab = 'on';
        else
            enab = 'off';
        end
        enabdynprop(this, 'ExportAs', enab);
    else
        addexportasprop(this);
    end
    
    % Return the labels and names so that we can create a
    % siggui.labelsandvalues object with the correct number of values.
    
    if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
        if strcmpi(this.ExportAs,'Objects'),
            [lbls, names]   = parse4obj(this);
            olbls = parse4vec(this);
        else
            [lbls, names]  = parse4vec(this);
            olbls = parse4obj(this);
        end
    else
        [lbls, names]  = parse4vec(this);
        olbls = {};
    end
        
    % Create and a component with the updated information.
    newHlnv = siggui.labelsandvalues('maximum',max(length(lbls), length(olbls)));
    addcomponent(this,newHlnv);
    
    set(this,'VariableLabels',lbls,...
        'VariableNames',names);
    
    l = handle.listener(newHlnv, newHlnv.findprop('Values'), ...
        'PropertyPostSet', @lclvalues_listener);
    set(l, 'CallbackTarget', this);
    set(this, 'ValuesListener', l);
        
    if isrendered(this),
        % Rerender labels and values
        
        pos = getpixelpos(this, 'framewlabel', 1);
        % Keep the x, and y, but replace the width and height.
        [pos(3) pos(4)] = destinationSize(this);
        
        send(this, 'NewFrameHeight');

        thisrender(this, pos); 
    end
end

% ----------------------------------------------------------------
function lclvalues_listener(this, eventData)

send(this, 'UserModifiedSpecs');
savenames(this);

% [EOF]
