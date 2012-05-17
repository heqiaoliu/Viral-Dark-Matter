function varargout = design(this, method, varargin)
%DESIGN   Design a filter.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:36:20 $

% Get all the design object constructors.
d = getdesignobj(this);

% Make sure that there is a butter field for us to use.
if ~isfield(d, method)
    error(generatemsgid('invalidDesign'), ...
        sprintf('%s is not defined for these specifications.', upper(method)));
end

% Build the object.
d = feval(d.(method));

% Set any option inputs into the design object.
if nargin > 2
    % First search for a structure of options and set them
    for k = 1:length(varargin),
        if isstruct(varargin{k}),
            set(d,varargin{k});
            varargin = {varargin{1:k-1},varargin{k+1:end}};
            break;
        end
    end
    
    % Set any p-v pairs specified
    
    for indx = 1:2:length(varargin)
        if isprop(d, varargin{indx})
            set(d, varargin{indx:indx+1});
        else
            error(generatemsgid('invalidOption'), ...
                sprintf('''%s'' is not a valid design option for %s.', ...
                varargin{indx}, upper(method)));
        end
    end
end

% Design the filter.
[varargout{1:nargout}] = design(d, this);

% [EOF]
