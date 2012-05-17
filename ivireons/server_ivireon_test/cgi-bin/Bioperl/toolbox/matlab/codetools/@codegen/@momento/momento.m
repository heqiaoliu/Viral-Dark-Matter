function varargout = momento(varargin)
% Constructor for the momento object.
% Traverse UDD hierarchy and create a parellel
% hierarchy of momento objects which encapsulate visible, 
% non-default properties

%   Copyright 2006-2008 The MathWorks, Inc.

% Syntax: codegen.momento(h,options)
%         codegen.momento(h,options,momento_parent)

if nargout == 1
    varargout{1} = local_construct_obj(varargin{:});
else
    local_construct_obj(varargin{:})
end

function varargout = local_construct_obj(h,options,momento_parent)
% Get this object's children
h = handle(h);
if ~local_does_support_codegen(h)
    return;
end

hThis = codegen.momento;
if nargin == 3
    % Add momento object to hierarchy
    connect(hThis,momento_parent,'up');
end

if isa(h,'hg.GObject')
   % ToDo: Remove double cast to double after HG seg-v's are fixed.
   kids = findall(double(h),'-depth',1);
elseif ishandle(h)
   kids = find(h,'-depth',1);
else
   error('MATLAB:codegen:momento:invalidHandle','Invalid handle')
end

% Determine traversal direction
if options.ReverseTraverse
    start = 2;
    stop = length(kids);
    increment = 1;
else
    start = length(kids);
    stop = 2;
    increment = -1;
end

% Recurse down to the children, ignoring this object
for n = start:increment:stop
     kid = kids(n);
     
     % If object wants its child to be represented in m-code, then 
     % recurse down. 
     if ~local_mcodeIgnore(h,kid)
        % Create momento object and recurse down to children
        local_construct_obj(kid,options,hThis);
     end
     
end % for

if ~local_mcodeIgnore(h,h)
   % Populate momento object with visible non-default 
   % properties corresponding to object, h
   local_populate_momento_object(hThis,h,options);
end

if nargout == 1
    varargout{1} = hThis;
end

%----------------------------------------------------------%
function [retval] = local_does_support_codegen(h)
% Object must be an HG primitives or implement the mcode generation
% interface

retval = true;
if ishandle(h)
   package_name = get(get(classhandle(h),'Package'),'Name');
   if ~strcmp(package_name,'hg') && ...
      ~ismethod(h,'mcodeConstructor') && ...
      ~ismethod(h,'mcodeIgnoreHandle')
         retval = false;
   end
end

%----------------------------------------------------------%
function local_populate_momento_object(momento,h,options)
% Add property info to momento object

constr = h.classhandle.Name;
set(momento,'Name',constr);
set(momento,'ObjectRef',h);

cls = classhandle(h);
allprops = get(cls,'Properties');

% Some properties are incorrect using handles. Cast graphics objects to
% double for the time being:
if isa(h,'hg.GObject')
    h = double(h);
end

% Loop through property objects
for n = length(allprops):-1:1
   prop = allprops(n);
   prop_name = get(prop,'Name');
   is_visible = strcmp(get(prop,'Visible'),'on');
   is_public_set = strcmp(prop.AccessFlags.PublicSet,'on');
   is_public_get = strcmp(prop.AccessFlags.PublicGet,'on');

   % Ignore properties that are not visible and public settable
   if is_visible && is_public_get && is_public_set 
           
       % If object says its okay to store this property
       if ~(local_mcodeIgnoreProperty(handle(h),prop))
           
          prop_val = get(h,prop_name);
          
          % Determine if the property should be an input argument to
          % the function
          is_parameter = local_mcodeIsParameter(handle(h),prop);
          
          % Store property info
          pobj = codegen.momentoproperty;
          set(pobj,'Name',prop_name);
          % If the property is a handle, recurse to its properties. If the
          % property name is "Parent", it must be treated differently,
          % otherwise there is a danger of an infinite loop. Make sure to
          % skip objects with their own constructors and values
          % corresponding to figure windows and the root object (0).
          if isscalar(prop_val) && ishandle(prop_val) && ...
                  ~strcmpi(prop_name,'Parent') && ...
                  ~isa(handle(prop_val),'hg.figure') && ...
                  ~isa(handle(prop_val),'hg.root') && ...
                  ~ismethod(prop_val,'mcodeConstructor')
              set(pobj,'Value',local_construct_obj(handle(prop_val),options));
          else
              set(pobj,'Value',prop_val);
          end
          set(pobj,'Object',prop);
          set(pobj,'IsParameter',is_parameter);
          tmp = get(momento,'PropertyObjects');
          set(momento,'PropertyObjects',[tmp,pobj]);
       end
   end % if
end % for

%----------------------------------------------------------%
function [bool] = local_mcodeIgnore(h1,h2)
% Determine whether we should query object

% If HGObject, delegate to behavior object
flag = true;
if ishghandle(h1)
    
    % Check app data
    info = getappdata(h1,'MCodeGeneration');
    if isstruct(info) && isfield(info,'MCodeIgnoreHandleFcn')
        fcn = info.MCodeIgnoreHandleFcn;
        if ~isempty(fcn)
            bool = hgfeval(fcn,h1,h2);
            flag = false;
        end
        
    % Check behavior object    
    else
        % ToDo: Consider deprecating use of behavior object since it is
        % a performance hit at creation time. 
        hb = hggetbehavior(h1,'MCodeGeneration','-peek');
        if ~isempty(hb)
            fcn = get(hb,'MCodeIgnoreHandleFcn');
            if ~isempty(fcn)
                bool = hgfeval(fcn,h1,h2);
                flag = false;
            end
        end
    end
end

% Delegate to object if it implements interface
if flag
   if ismethod(h1,'mcodeIgnoreHandle') 
      bool = mcodeIgnoreHandle(h1,h2);
   else
      bool = codetoolsswitchyard('mcodeDefaultIgnoreHandle',h1,h2);
   end
end

%----------------------------------------------------------%
function [bool] = local_mcodeIsParameter(hObj,hProp)
% Determine whether the property should be a parameter

% Delegate to object if it implements interface
if ismethod(hObj,'mcodeIsParameter')
    bool = mcodeIsParameter(hObj,hProp);
else
    bool = codetoolsswitchyard('mcodeDefaultIsParameter',hObj,hProp);
end

%----------------------------------------------------------%
function [retval] = local_mcodeIgnoreProperty(hObj,hProp)
% Determine whether we should serialize property to the 
% momento object

retval = false; %#ok, suppress mlint warnings
prop_name = get(hProp,'Name');

% Special case for GObjects
if isa(hObj,'hg.GObject') && local_mcodeIgnoreHGProperty(hObj,hProp)
    retval = true;

% Ignore properties that have default factory values
% We don't do this test on HG objects because this test was already
% ran above
elseif ~isa(hObj,'hg.GObject') && isequal(get(hObj,prop_name),get(hProp,'FactoryValue'))
    retval = true;

% Delegate to object if it implements interface
elseif ismethod(hObj,'mcodeIgnoreProperty') &&  mcodeIgnoreProperty(hObj,hProp);
    retval = true;
    
% Do the default   
else
    retval = codetoolsswitchyard('mcodeDefaultIgnoreProperty',hObj,hProp);
end

%----------------------------------------------------------%
function [bool] = local_mcodeIgnoreHGProperty(hObj,hProp)
% Ignore HG properties generic to all GObjects

bool = false;

prop_name = get(hProp,'Name');
instance_value = get(hObj,prop_name);
obj_name = get(hObj,'Type');
default_prop_name = ['Default',obj_name,prop_name]; 
has_hg_default = false;

% If the object is an hg primitive (or subclass), ignore 
% the value of the property if it is an HG root default. 
if ~isa(hObj,'hg.hggroup') && ~isa(hObj,'hg.hgtransform') 
     % Can't use FINDPROP here to test for property since some 
     % root properties are not registered with UDD. 
     % When that is fixed, the try/end can be removed. 
     try
         default_value = get(0,default_prop_name);
         has_hg_default = true;
         bool = isequal(default_value,instance_value);
     catch anError  %#ok<NASGU> avoids lasterr cruft
     end
end

% Ignore property if value is a UDD default 
if ~bool && ~has_hg_default
   factory_value = get(hProp,'FactoryValue');
   bool = isequal(factory_value,instance_value);    
end

% Do not ignore property if there is a "mode" property associated with it:
mode_property_name = [prop_name,'Mode'];
if ~isempty(findprop(hObj,mode_property_name))
    bool = false;
end
