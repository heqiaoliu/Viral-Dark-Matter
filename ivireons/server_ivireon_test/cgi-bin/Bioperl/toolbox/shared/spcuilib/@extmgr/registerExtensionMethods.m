function registerExtensionMethods(hDerived)
%REGISTEREXTENSIONMETHODS Register extension static methods.
%   extmgr.registerExtensionMethods(HCLASS) registers the static methods
%   used by the extension manager on subclasses of extmgr.AbstractExtension
%   This function must be called whenever a subclass overloads one of these
%   methods.  If none of these methods are overloaded, calling this
%   function will be a NO OP.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/08 21:43:44 $

% Register getPropertyDb static method.
methodName = 'getPropertyDb';
m = find(hDerived, 'Name', methodName);
if ~isempty(m)
    findclass(findpackage('extmgr'), 'PropertyDb');
    m = schema.method(hDerived, methodName, 'static');
    set(m.Signature, ...
        'varargin',    'off', ...
        'InputTypes',  {}, ...
        'OutputTypes', {'extmgr.PropertyDb'});
end

methodName = 'getPropsSchema';
m = find(hDerived, 'Name', methodName);
if ~isempty(m)
    findclass(findpackage('extmgr'), 'Config');
    findclass(findpackage('DAStudio'), 'Dialog');
    m = schema.method(hDerived, methodName, 'static');
    set(m.Signature, ...
        'varargin',    'off', ...
        'InputTypes',  {'extmgr.Config', 'DAStudio.Dialog'}, ...
        'OutputTypes', {'mxArray'});
end

methodName = 'validate';
m = find(hDerived, 'Name', methodName);
if ~isempty(m)
    findclass(findpackage('DAStudio'), 'Dialog');
    m = schema.method(hDerived, methodName, 'static');
    set(m.Signature, ...
        'varargin',    'off', ...
        'InputTypes',  {'DAStudio.Dialog'}, ...
        'OutputTypes', {'bool', 'mxArray'});
end

methodName = 'postOptionsDialogApply';
m = find(hDerived, 'Name', methodName);
if ~isempty(m)
    findclass(findpackage('DAStudio'), 'Dialog');
    m = schema.method(hDerived, methodName, 'static');
    set(m.Signature, ...
        'varargin',    'off', ...
        'InputTypes',  {'DAStudio.Dialog'}, ...
        'OutputTypes', {'bool', 'mxArray'});
end

% [EOF]
