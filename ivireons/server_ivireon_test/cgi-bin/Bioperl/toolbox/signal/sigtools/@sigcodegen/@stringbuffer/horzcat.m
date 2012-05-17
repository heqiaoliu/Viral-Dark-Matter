function H = horzcat(varargin)
%HORZCAT Horizontal concatenation method for StringBuffer.
%   Horizontal concatenation directly appends the buffers.
%   Note that horizontal and vertical concatenation perform
%   identical operatinos.
%
%   Multiple stringbuffer objects may be retained in
%   a cell-array.
%
%   See also STRINGBUFFER/VERTCAT.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:45 $

% Check that all inputs are STRINGBUFFER objects
H = copy(varargin{1});  % take the first input
for i=2:nargin,
    if ischar(varargin{i}) || iscellstr(varargin{i}),
        if isempty(H),
            H.add(varargin{i});
        else,
            H.cradd(varargin{i});
        end
    elseif isa(varargin{i},'sigcodegen.stringbuffer'),
        if ~isempty(varargin{i})
            H.buffer = [H.buffer varargin{i}.buffer];
        end
    else
        error(generatemsgid('InvalidParam'),['StringBuffer objects can only be concatenated with ' ...
                'other StringBuffer objects and with chars.']);
    end
end

% [EOF]
