function str = generateParseInputsFcns(allProps, sysObj, defaults, returnStruct)
    % generateParseInputsFcns
    %
    % This function is undocumented and unsupported.  It is needed for the
    % correct functioning of your installation.
    
    % GENERATEPARSEINPUTS - generate the pv-pair parsing code for a classdef.
    %   allProps - public property names (cell array of strings)
    %   sysObj - name of System object
    %   defaults - default values for public properties (cell array of
    %   strings corresponding to allProps; [] for props with no default).
    %   returnStruct - if true, generate a return structure for testing.
    
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:19:05 $

    %#ok<*AGROW>
    
    if nargin < 4
        returnStruct = false;
    end
    
    str = generateParseInputs(sysObj, allProps, defaults, returnStruct);
end

function str = generateParseInputs(sysObj, allProps, defaults,returnStruct)

    if isempty(allProps)
        % trivial case - no parseable properties
        str = [...
            'function ret = parseInputs(varargin)'  newline...
            '    ret = [];'                         newline...
            'end % parseInputs'                     newline...
                                                    newline...
            ];
        % no generateParseArgs()
        return;
    end
    
    valueOnlyProps = getValueOnlyProperties(sysObj,allProps);
    
    if isempty(valueOnlyProps)
        % common trivial case - no valueOnlyProps
        str = [...
            'function ret = parseInputs(varargin)'  newline...
            '    ret = parseArgs(varargin{:});'     newline...
            'end % parseInputs'                     newline...
                                                    newline...
            generateParseArgs(allProps, defaults,returnStruct)...
            ];
        return;
    end
    
    str = {};

    str{end+1} = [...
        'function ret = parseInputs(varargin)'                          newline...
        '%#eml'                                                         newline...
        '    nValOnlyArgs = eml_const(getNValOnlyArgs(varargin{:}));'   newline...
        '    switch nValOnlyArgs'                                       newline...
        ];
    
    for i = 0:length(valueOnlyProps)
        str{end+1} = sprintf([...
            '        case %d\n'...
            '            ret = parseArgs('], i...
            );
        
        for j = 1:i
            str{end+1} = sprintf('''%s'', varargin{%d}, ', valueOnlyProps{j}, j);
        end
        
        str{end+1} = sprintf('varargin{%d:end});\n', i+1);
    end
    
    str{end+1} = [...
        '    end'               newline...
        'end % parseInputs'     newline...
                                newline...
        ];
    
    str{end+1} = generateIsPropName(allProps);
    str{end+1} = generateGetNValOnlyArgs;
    
    str{end+1} = generateParseArgs(allProps, defaults,returnStruct);

    str = [str{:}];
end

function str = generateParseArgs(allProps, defaults, returnStruct)
    str = {};
    
    str{end+1} = [...
        'function ret = parseArgs(varargin)'   newline...
        '    params = struct('
        ];
    comma = '';
    for i = 1:length(allProps)
        str{end+1} = sprintf('%s...\n        ''%s'', uint32(0)', comma, allProps{i});
        comma = ',';
    end
    
    str{end+1} = [...
        ');'                                                        newline...
                                                                    newline...
        '    opts = struct(''CaseSensitivity'',true,'...
                          '''StructExpand'', true);'                newline...
                                                                    newline...
        '    s = eml_parse_parameter_inputs(params, opts, varargin{:});' newline...
                                                                    newline...
        ];

%     p = {allProps{:}; allProps{:}; defaults{:}};
%     str{end+1} = ...
%         sprintf('    %s = eml_get_parameter_value(s.%s, %s, varargin{:});\n',p{:});

    for i = 1:length(allProps)
        p = allProps{i};
        d = defaults{i};
        v = sprintf('v%d',i);
        str{end+1} = [...
            '    ' v ' = eml_get_parameter_value(s.' p ', ' d ', varargin{:});'   newline...
            '    if ~isempty(' v ')'                                newline...
            '        ' p ' = ' v ';'                                newline...
            '    end'                                               newline...
            ];
    end
    

    if returnStruct
        str{end+1} = [...
                                                                    newline...
            '    ret = struct('
            ];
        comma = '';
        for i = 1:length(allProps)
            str{end+1} = sprintf('%s...\n        ''%s'', %s', comma, allProps{i}, allProps{i});
            comma = ',';
        end
        str{end+1} = [...
            '...'                                                       newline...
            '        );'                                                newline...
            newline...
            ];
    else
        str{end+1} =                    newline;
        str{end+1} = ['    ret = 0;'    newline];
        str{end+1} =                    newline;
    end
    
    str{end+1} = ['end % parseArgs' newline];
    str{end+1} = newline;

    str = [str{:}];
end

function str = generateIsPropName(allProps)
    str = {};
    
    str{end+1} = [...
        'function idx = isPropName(name)'   newline...
        '    switch name'                   newline...
        ];
    
    for i = 1:length(allProps)
        str{end+1} = sprintf([...
            '        case ''%s'''       newline...
            '            idx = %d;'     newline...
            ], allProps{i}, i);
    end
    
    str{end+1} = [...
        '        otherwise'             newline...
        '            idx = 0;'          newline...
        '    end'                       newline...
        'end % isPropName'              newline...
                                        newline...
        ];
    
    str = [str{:}];
    
end

function str = generateGetNValOnlyArgs
    str = [...
        'function n = getNValOnlyArgs(varargin)'            newline...
        '    n = 0;'                                        newline...
        '    for i = eml.unroll(1:nargin)'                  newline...
        '        if eml_is_const(varargin{i}) ...'          newline...
        '           && eml_const(isPropName(varargin{i}))'  newline...
        '            break;'                                newline...
        '        end'                                       newline...
        '        n = n + 1;'                                newline...
        '    end'                                           newline...
        'end'                                               newline...
                                                            newline...
        ];
end

function s = newline
    s = char(10);
end

% There are several options for getting the value-only properties,
% which are defined in the static class method getValueOnlyProperties:
%
% 1) invoke the static class method
%       (this is used below)
%
% 2) assume a cell array of strings and parse them out:
%
%     function props = getValueOnlyProps
%         props = { 'foo' 'bar' };
%     end
%
% 3) assume a slightly more general syntax and eval the rhs:
%
%     function props = getValueOnlyProps
%         props = whatever...
%     end
% For posterity, here's code that does (3):
%
% function props = getValueOnlyProperties(T)
%     F = mtfind(T, 'Fname.String', 'getValueOnlyProps');
%     F = mtfind(F,...
%         'Body.Next.Null', true,...              % only 1 stmt in body, and
%         'Body.Kind',    'EXPR', ...             % it's an
%         'Body.Arg.Kind','EQUALS', ...           % assignment
%         'Body.Arg.Left.SameID', F.Outs);        % to the output.
%     assert(F.count == 1);
%     rhs = F.Body.Arg.Right;
%     props = eval(tree2str(rhs,0,true));
% end

function props = getValueOnlyProperties(sysObj, parseableProps)
    try
        method = [sysObj '.getValueOnlyProps'];
        props = eval(method);
    catch me
        warning([mfilename ':GetValueOnlyPropsMethodFailed'],...
            'attempt to call static method ''%s'' failed: %s',...
            method, me.message);
        props = {};
    end
    
    props = filterNonExistingProps(props,parseableProps);

    function props = filterNonExistingProps(props, parseableProps)
        diff = setdiff(props, parseableProps);
        if ~isempty(diff)
            nonprops = sprintf(' ''%s''',diff{:});
            warning([mfilename ':GetValueOnlyPropsNotProps'],...
                '%s.getValueOnlyProperties() returned non-existent properties:%s',...
                sysObj, nonprops);
            props = setdiff(props, diff);
        end
    end
end

