function [varargout] = rmi_explr_util(method, obj, varargin)
% RMI Requirements Management Interface API gateway
% Used for actions that do not necessarily require VnV license,
% or as a wrapper for direct reqmgt calls to ensure consistency
% of the Simulink/Stateflow editor windows.
%
%   Example:
%     RESULT = rmi_explr_util('highlightModel', OBJ) highlights
%     objects in the model that have requirements
%
%   See also RMI

%   Copyright 2003-2010 The MathWorks, Inc.

    % Cache variable argument size
    switch(lower(method))

    case 'getmodelh'
        varargout{1} = rmisl.getmodelh(obj);

    case 'vnvlicenseactive'
        varargout{1} = vnv_license_active();

    case 'highlightmodel'
        modelH = rmisl.getmodelh(obj);
        if modelH ~= 0   % '0' may happen for a DefaultBlockDiagram
            rmi('highlight', modelH, 'on');
        end

    case 'unhighlightmodel'
        modelH = rmisl.getmodelh(obj);
        if modelH ~= 0   % '0' may happen for a DefaultBlockDiagram
            rmi('highlight', modelH, 'off');
        end

    case 'doorsinstalled'
    varargout{1} = false;
    try
        if ispc
            % This is the DOORS support recommended way of determining
            % if DOORS is installed.  The other option is to attempt to
            % create the COM object, the disadvantage of which is it will
            % launch the DOORS and ask you to login.  If this key doesn't
            % exist, the following will error out.
            winqueryreg('name', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Telelogic\DOORS');
            varargout{1} = true;
        end;
    catch Mex %#ok<NASGU>
    end

    otherwise
        error('SLVNV:rmi_explr_util:UnknownMethod','Unknown Method');
    end


function result = vnv_license_active()
    result = false;
    licenseInUse=license('inuse');
    for licenseused=licenseInUse(:)'
        if strcmpi('sl_verification_validation', licenseused.feature)
            result = true;
            break;
        end
    end





