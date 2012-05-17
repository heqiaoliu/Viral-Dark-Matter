function clean_up_truth_table_content(ttId)

% Copyright 2004-2005 The MathWorks, Inc.

if ~is_truth_table_fcn(ttId)
    return;
end

% Clean up generated diagram
rt = sfroot;
ttObject = rt.idToHandle(ttId);

ttContents = ttObject.find;
for i = 1:length(ttContents)
    if ishandle(ttContents(i)) && ttContents(i) ~= ttObject
        skipDeletion = 0;
        if strcmp(get(classhandle(ttContents(i)), 'Name'), 'Data')
            skipDeletion = ~sf('get', ttContents(i).Id, 'data.autogen.isAutoCreated');
        end
        if ~skipDeletion
            delete(ttContents(i));
        end        
    end
end

% Clean up EML representation
% Trun off side effects
sf('TurnOffEMLUIUpdates',1);
sf('TurnOffPrototypeSync',1);

sf('set', ttId, 'state.eml.script', '', 'state.eml.breakpoints', [], 'state.eml.inferBkpts',[]);
sf('set', ttId, 'state.autogen.mapping', []);
sf('set', ttId, 'state.eml.cvMapInfo', []);

sf('TurnOffPrototypeSync',0);
sf('TurnOffEMLUIUpdates',0);

% Close opened eML script window if NOT using eML
if ~is_eml_truth_table_fcn(ttId)
    eml_man('force_close_ui', ttId);
end

return;
