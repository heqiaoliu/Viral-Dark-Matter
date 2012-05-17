function pvparse(varargin)
%PVPARSE  Property value pairs parsing
%   PVPARSE(VARARGIN) parses the property values into the corresponding
%   variables in the caller workspace.  The variable holding the property
%   values must have the same name as the property name (case insensitive).
%
%   This is a private function.
%
%   Example:
%       % Parse the variable changeme from 1 to 2 using property value
%       % pairs.
%       changeme = 1;
%       sigutils.pvparse('ChangeMe',2);
%       changeme

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2008/08/22 20:33:32 $


varnames = evalin('caller','whos');
vnames = {varnames.name};
if ~isempty(varargin)
    if mod(numel(varargin),2)
        error(generatemsgid('MustBeInPairs'),...
            'Each parameter specified must have a corresponding value.');
    end
    for m = 1:2:nargin
        indx = find(strncmpi(vnames, varargin{m}, length(varargin{m})));
        switch length(indx)
            case 0
                error(generatemsgid('UnknownInput'),...
                    ['Input parameter ' varargin{m} ' not recognized.']);
            case 1
                assignin('caller', vnames{indx}, varargin{m+1});
            otherwise
                matchFlag = false;
                for n = 1:length(indx)
                    if length(vnames{indx(n)}) == length(varargin{m})
                       assignin('caller', vnames{indx(n)}, varargin{m+1});
                       matchFlag = true;
                       break;
                    end
                end
                if ~matchFlag
                    error(generatemsgid('AmbiguousInput'),...
                        ['Input parameter ' varargin{m} ' is ambiguous.']);
                end
        end
    end
end


% [EOF]
