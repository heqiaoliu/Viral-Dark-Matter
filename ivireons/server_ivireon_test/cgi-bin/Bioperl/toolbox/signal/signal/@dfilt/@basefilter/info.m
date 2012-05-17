function varargout = info(this, varargin)
%INFO Information about filter.
%   S = INFO(Hd) returns a string matrix with information about the filter.
%
%   See also DFILT.

%   Author: R. Losada, J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.10 $  $Date: 2006/11/19 21:44:32 $

if nargin > 2
    error(generatemsgid('wrongnumArguments'), 'Wrong number of arguments are passed.');
end
if nargin == 2
    if ~iscellstr(varargin)
        error(generatemsgid('wrongtypeArguments'), 'Argument must be one of the strings ''short'' or ''long''');
    else
        if ~(strcmpi(varargin{:},'short') ||  strcmpi(varargin{:}, 'long'))
            error(generatemsgid('wrongArgumentstring'), 'Invalid string ''%s''. Valid arguments are ''short'' & ''long''.', varargin{:});
        else
            format = varargin{:};
        end
    end
else % nargin == 1
    format = 'short'; % default
end
[p, v] = thisinfo(this);

infostrs = getinfoheader(this);

% If there is no extra information, just show the title.
if ~isempty(p)

    spacerindx = find(strcmp(p, 'spacer') & strcmp(v, 'spacer')); %#ok

    p(spacerindx) = {' '};
    v(spacerindx) = {' '};

    infostrs = { ...
        infostrs, ...
        repmat('-', 1, size(infostrs, 2)), ...
        [strvcat(p{:}) repmat('  : ', length(p), 1), strvcat(v{:})], ...
        };

    % Remove the extra ':'
    infostrs{end}(spacerindx, :) = ' ';

    infostrs = strvcat(infostrs{:});
end

if strcmpi(format, 'long')
    % Add the measurements to the information if they are present.
    if isfdtbxinstalled

        % Add the design method
        desmeth = this.privdesignmethod;
        if ~isempty(desmeth),
            desmethstr = ['Design Algorithm', ' : ', desmeth];
            infostrs = strvcat(infostrs, ' ', 'Design Method Information', desmethstr);
        end

        fmeth = this.privfmethod;
        if ~isempty(fmeth) && ~isempty(fmeth.tostring),
            infostrs = strvcat(infostrs, ' ', 'Design Options', fmeth.tostring);
        end

        % Add the design specs
        fdes = this.privfdesign;
        if ~isempty(fdes),
            infostrs = strvcat(infostrs, ' ', 'Design Specifications', fdes.tostring);
        end

        m = measure(this);
        if ~isempty(m)
            infostrs = strvcat(infostrs, ' ', 'Measurements', m.tostring);
        end

        % Add cost
        try
            % Cost will fail for certain structures like statespace
            c = cost(this);
            infostrs = strvcat(infostrs, ' ', 'Implementation Cost', c.tostring);
        catch
            % Do nothing
        end
    end
end

if nargout
    varargout = {infostrs};
else
    disp(infostrs);
end


% [EOF]
