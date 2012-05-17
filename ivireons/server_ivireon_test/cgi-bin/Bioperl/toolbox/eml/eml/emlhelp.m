function x = emlhelp(topic)
%EMLHELP brings up online help and documentation for Embedded MATLAB.
%

%   Copyright 2009 The MathWorks, Inc.

x = [];
result = execute_topic(topic);

if nargout == 1
    x = result;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = execute_topic(topic)

t = lookup_local_topic(topic);

if isempty(t)
    % The topic doesn't exist anywhere. This should never happen.
    warning('eml:helpview', ...
        'Invalid help topic ''%s''. Opening default help page.',topic);
    helpdesk;
else
    if isa(t{2},'function_handle')
        f = t{2};
        if nargout(f) > 0
            t = f();
        else
            f();
        end
    else
        helpview(t{3},t{2});
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = lookup_local_topic(topic)

T = topic_map;

I = strmatch(topic,T(:,1),'exact');

if isempty(I)
    t = [];
else
    t = T(I(1),:);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = rtw_map
s = fullfile(docroot,'toolbox','rtw','helptargets.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = eml_map
s = fullfile(docroot,'toolbox','eml','eml.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = topic_map

%This table isolates us from changes in the MAP files and makes
% it possible to automatically test that the map-files aren't changed
% without the appropriate changes in the code base.
  
helpTopics = ...
    { ...  
    %internal topic,    link (mapfile topic),           map file
    'rtwdialog',        'help_button_rtw',              rtw_map;
    'mexdialog',        'help_button_mex',              rtw_map;
    'hardwaredialog',   'help_button_himp',             rtw_map;
    'coptionsdialog',   'help_button_compile_options',  eml_map;

    'eml_error_iemStaticDynamicSizeMismatchOnAssignment', 'size_mismatch_assignment_error', eml_map;
    'eml_error_icmPreconditionInferenceFailed', 'def_input_prop_prog', eml_map;
    };

t = [{ '-topics',@topic_map, ''}
       helpTopics;...
       ];

end


% EOF: emlhelp.m
