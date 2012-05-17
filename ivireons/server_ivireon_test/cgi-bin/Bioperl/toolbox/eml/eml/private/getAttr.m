function attrVal = getAttr(treeNode, attrName)
    % getAttr
    %
    % This function is undocumented and unsupported.  It is needed for the
    % correct functioning of your installation.
    
    % getAttr - get the value of an attribute for a property or method.
    % treeNode must be an mtree object containing exactly one node that
    % represents a function, a property, a function section, or a property
    % section.
    % attrName - the name of the attribute to find the value of.
    
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:15:02 $
    
    attrVal = [];
    
    if ~isa(treeNode,'mtree')
        error('getAttr:WrongClass', ...
            'getAttr: treeNode has class ''%s''.', class(treeNode));
    end
    
    if count(treeNode) ~= 1
        error('getAttr:TooMany', ...
            'getAttr: treeNode must be a single node');
    end
    
    if iskind(treeNode, 'FUNCTION')
        section = trueparent(treeNode);
        if section.count == 0
            error('getAttr:SubFunction', ...
                'getAttr: treeNode is subfunction ''%s''; must be a method ''%s''.', string(Fname(treeNode)));
        end
    elseif iskind(treeNode, 'EQUALS') && iskind(trueparent(treeNode), 'PROPERTIES')
        section = trueparent(treeNode);
    elseif iskind(treeNode, {'PROPERTIES' 'METHODS'})
        section = treeNode;
    else
        error('getAttr:UnknownKind', ...
            'getAttr: treeNode has unrecognized kind ''%s''.', kind(treeNode));
    end
    
    if iskind(section, 'PROPERTIES')
        switch attrName
            case { ...
                    'AbortSet'      ...
                    'Abstract'      ...
                    'Constant'      ...
                    'Dependent'     ...
                    'GetObservable' ...
                    'Hidden'        ...
                    'SetObservable' ...
                    'Transient'     ...
                    }
                attrVal = getAttrVal(section,attrName,'false','true');
            case {'Access' 'SetAccess' 'GetAccess'}
                attrVal = getAttrVal(section,attrName,'public','');
            otherwise
                error('getAttr:UnknownAttr', ...
                    'getAttr: ''%s'' is not a recognized property attribute.', attrName);
        end
    elseif iskind(section, 'METHODS')
        switch attrName
            case { ...
                    'Abstract'  ...
                    'Hidden'    ...
                    'Sealed'    ...
                    'Static'    ...
                    }
                attrVal = getAttrVal(section,attrName,'false','true');
            case 'Access'
                attrVal = getAttrVal(section,attrName,'public','');
            otherwise
                error('getAttr:UnknownAttr', ...
                    'getAttr: ''%s'' is not a recognized method attribute.', attrName);
        end
    else
        assert(false);  % how did we get here?
    end
    
    assert( ~isempty(attrVal) );    % should have a value or have errored out
    
end

function attrVal = getAttrVal(section, attrName, absentVal, nullVal)
    % GETATTRVAL - get value of an attribute
    % SECTION - section to be searched for attribute
    % ATTRNAME - name of attribute to search for
    % ABSENTVAL - value if attribute does not appear
    % NULLVAL - value is attribute appears but has no assigned value
    attr = findAttr(section,attrName);
    if attr.count == 0
        % attribute not present
        attrVal = absentVal;
    elseif isnull(attr.Right)
        % attribute present without a value
        attrVal = nullVal;
    else
        attrVal = attr.Right.string;
        if attrVal(1) == '''' && attrVal(end) == ''''
            % strip quotes
            attrVal = attrVal(2:(end-1));
        end
    end
end

function attr = findAttr(section,attrName)
    % FINDATTR(SECTION, ATTRNAME) find attribute in SECTION with ATTRNAME
    attrList = List(Arg(Attr(section)));
    attr = mtfind(attrList,'Left.String', attrName);
    if attr.count > 1
        warning('findAttr:tooMany',...
            'found multiple ''%s'' attributes near line %d',...
            attrName, lineno(section));
        attr = first(attr);
    end
end
