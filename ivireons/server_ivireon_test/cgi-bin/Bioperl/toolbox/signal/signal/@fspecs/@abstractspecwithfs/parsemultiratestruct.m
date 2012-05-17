function [struct, varargin] = parsemultiratestruct(this, struct, varargin)
%PARSEMULTIRATESTRUCT   

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:28:05 $

if nargin > 3
    if ischar(varargin{end-1})
        if strcmpi(varargin{end-1}, 'filterstructure')
            struct = varargin{end};
            varargin(end-1:end) = [];
        end
    end
end

% [EOF]
