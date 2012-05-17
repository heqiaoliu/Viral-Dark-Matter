function out = javasetget(ejag,useSet,jobj,varargin)
% JAVASETGET Helper function to set and get properties on Java Objects.

% Copyright 2010 The MathWorks, Inc.

% make sure we have a Java objects
    if ~isjava(jobj)
        error('MATLAB:javaset:invalidinput','Third input must be a Java object')
    end

    if useSet
        minrhs = 3;
        maxrhs = inf;
    else
        minrhs = 3;
        maxrhs = 5;
    end

    error(nargchk(minrhs,maxrhs,nargin,'struct'))
    if nargout
        out = [];
    end
    if isempty(varargin)
        % just display the options
        cmd = 'get';
        if useSet
            cmd = 'set';
        end
        % just use handle - don't use lochandle so we don't
        % show all the callback properties.
        hobj = handle(jobj);
        if nargout
            out = feval(cmd,hobj);
        else
            disp(feval(cmd,hobj))
        end
        return
    end
    argc = length(varargin);

    ind = 1;
    while ind <= argc;
        prop = varargin{ind};
        if isstruct(prop)
            % if prop is a struct, then the field names and values
            % become the property names and values
            fields = fieldnames(prop);
            for ifield = 1:size(fields);
                field = fields(ifield);
                doprop(field{1}, prop.(field{1}))
            end
            ind = ind + 1;
        else
            % if prop isn't a struct, use the next arg as the value, if one
            if argc < ind+1
                doprop(prop)
            else
                doprop(prop, varargin{ind+1})
            end
            ind = ind + 2;
        end
    end

    % issue set/get on propname with optional propval, handling the
    % EnableJavaASGObject feature and special case of 'userdata'
    function doprop(propname, propval)
        if ejag == 0
            if (nargin == 2)
                dosetget(prop, propval)
            else
                dosetget(prop)
            end
        end
        lpropname = lower(propname);
        switch lpropname
            case 'userdata'
                if ejag == 3
                    warning('MATLAB:hg:JavaSetHGProperty','Deprecated use of get/set on a Java object with an HG Property.')
                end
                if useSet
                    if (nargin == 2)
                        javauserdata(useSet, jobj, propval);
                    else
                        fprintf('A %s''s "UserData" property does not have a fixed set of property values.', ...
                            class(jobj))
                    end
                else
                    out = javauserdata(useSet, jobj);
                end
            otherwise
                if (nargin == 2)
                    dosetget(propname, propval)
                else
                    dosetget(propname)
                end
        end
    end

    % issue set/get on propname and optional propval
    function dosetget(propname, propval)
        if useSet
            if (nargin == 1)
                set(lochandle(jobj),propname)
            else
                set(lochandle(jobj),propname,propval)
            end
        else
            % Error if nargin == 2
            out = get(lochandle(jobj),propname);
        end
    end

    function out=javauserdata(useSet, varargin)
        %JAVAUSERDATA Store userdata on a Java object or return the current value.
        if nargout
            out = javaprop(useSet, 'UserData','mxArray',varargin{:});
        else
            javaprop(useSet, 'UserData','mxArray',varargin{:});
        end
    end

    function out=javaprop(useSet, prop, dtype, jobj, value)
        if useSet
            if ~locisprop(jobj,prop)
                schema.prop(lochandle(jobj),prop,dtype);
            end
            set(lochandle(jobj),prop,value)
        else
            out = [];
            if locisprop(jobj,prop)
                out = get(lochandle(jobj),prop);
            end
        end
    end

    function yesno = locisprop(jobj,prop)
        yesno = ~isempty(findprop(lochandle(jobj), prop));
    end

    function hobj = lochandle(obj)
        % If the object passed in is a UDDObject, it's already been
        % converted to a handle and we need to grab the underlying
        % object. Calling handle with no args will do that.
        if isa(obj,'com.mathworks.jmi.bean.UDDObject')
            obj = handle(obj);
        end
        % If we can't convert the underlying object to a
        % handle, just let the dispatcher deal with it.
        try
            if ejag == 0
                hobj = handle(obj);
            else
                hobj = handle(obj,'callbackPropertiesonoff');
            end
            waserr = false;
        catch e
            waserr = ~isempty(e);
        end
        if waserr
            hobj = obj;
        end
    end
end
