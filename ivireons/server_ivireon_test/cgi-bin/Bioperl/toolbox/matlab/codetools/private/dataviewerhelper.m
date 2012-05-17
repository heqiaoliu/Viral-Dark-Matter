function varargout = dataviewerhelper(whichcall, varargin)
%DATAVIEWERHELPER Helper functions for Workspace, Variable Editor, and other tools

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:11:42 $

switch whichcall
    case 'upconvertIntegralType',
        varargout = {upconvertIntegralType(varargin{:})};
    case 'isUnsignedIntegralType',
        varargout = {isUnsignedIntegralType(varargin{:})};
    otherwise
        error('MATLAB:dataviewerhelper:unknownOption', ...
            'Unknown command option.');
end

%********************************************************************
function converted = upconvertIntegralType(value)
converted = value;
if ~isfloat(value)
    if isa(value, 'uint8')
        converted = uint16(value);
    end
    if isa(value, 'uint16')
        converted = uint32(value);
    end
    if isa(value, 'uint32')
        converted = uint64(value);
    end
end

%********************************************************************
function unsigned = isUnsignedIntegralType(value)
unsigned = false;
if ~isfloat(value)
    unsigned = isa(value, 'uint8') || isa(value, 'uint16') || ...
        isa(value, 'uint32') || isa(value, 'uint64');
end