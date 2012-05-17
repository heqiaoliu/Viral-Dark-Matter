function varargout = superdesign(this, method, varargin)
%SUPERDESIGN   Design the filter.
%   This method is used to enable subclasses that overwrite design method to 
%   call design method of the super class.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/31 00:00:13 $

% This should be a private method.

if nargin < 2
    method = 'default';
else
    validflags = {'all', 'allfir', 'alliir', 'default', 'fir', 'iir'};
    if ~isdesignmethod(this, method) && ~any(strcmpi(method, validflags))
        varargin = [{method}, varargin];
        method = 'default';
    end
end

method = lower(method);

switch method
    case 'all'
        d = designmethods(this);
        Hd = {};
        for indx = 1:length(d)
            try
                Hd{end+1} = feval(d{indx}, this); %#ok<AGROW>
            catch me %#ok<NASGU>
                warning(generatemsgid('FailedDesign'), '''%s'' failed.', d{indx});
            end
        end

        Hd = [Hd{:}];

        varargout = {Hd};
    case {'alliir', 'allfir'}
        d = designmethods(this, method(4:end));
        if isempty(d)
            error(generatemsgid('invalidMethod'),...
                'There are no %s designs for specification type: ''%s''.', ...
                upper(method(4:end)), this.SpecificationType);
        end
        Hd = {};
        for indx = 1:length(d)
            try
                Hd{end+1} = feval(d{indx}, this); %#ok<AGROW>
            catch me %#ok<NASGU>
                warning(generatemsgid('FailedDesign'), '''%s'' failed.', d{indx});
            end
        end
        Hd = [Hd{:}];
        varargout = {Hd};
    case 'default'
        d = defaultmethod(this);
        if nargin > 1 && ~isstruct(varargin{1}) && ~isnumeric(varargin{1})  && ...
                ~any(strcmpi(fieldnames(designopts(this,d)),varargin{1})),
            % An invalid method was specified
            error(generatemsgid('invalidDesignMethod'),...
                [varargin{1},' is an invalid design method.']);
        end
        if nargin > 1 && rem(length(varargin),2) && ~isstruct(varargin{1}) ...
                && ~isnumeric(varargin{1}),
            error(generatemsgid('invalidPVpairs'),...
                'Design options must be specified as a structure or as parameter-value pairs.');
        end
        Hd = feval(d, this, varargin{:});
        varargout = {Hd};
    case {'fir', 'iir'}
        d = designmethods(this, method);
        if isempty(d)
            error(generatemsgid('invalidMethod'),...
                'There are no %s designs for specification type: ''%s''.', ...
                upper(method), this.SpecificationType);
        end
        if strcmpi(method, 'fir') && any(strcmpi(d, 'equiripple'))
            d = 'equiripple';
        elseif strcmpi(method, 'iir') && any(strcmpi(d, 'ellip'))
            d = 'ellip';
        else
            d = d{1};
        end
        Hd = feval(d, this);
        varargout = {Hd};
    otherwise
        % hiddenmethods is there for backwards compatibility (for example
        % butter needs to work for 'N,Fc' (lowpass) although it is no
        % longer a valid designmethod (we changed it to 'N,F3dB'))
        if any(strcmpi(method, designmethods(this))) || ...
                any(strcmpi(method, hiddenmethods(this)))
            % Check for valid p-v pairs, but first remove any possible
            % options structure
            if nargin > 2,
                args = varargin;
                for k = 1:length(args),
                    if isstruct(args{k}),
                        args(k) = [];
                    end
                end
                if rem(length(args),2) && ~isnumeric(args{1}),
                    error(generatemsgid('invalidPVpairs'),...
                        'Design options must be specified as a structure or as parameter-value pairs.');
                end
            end
            Hd = feval(method, this, varargin{:});
            varargout = {Hd};
            if any(strcmpi(method, hiddenmethods(this))),
                warning(generatemsgid('Obsolete'), ...
                    ['The ''butter'' design method is obsolete. ', ...
                    'Using ''butter'' with Fc specification sets still works ',...
                    'but will be removed in the future. Use a specification with F3dB instead.']);
            end
        else
            error(generatemsgid('invalidMethod'),...
                '%s is not defined for specification type: ''%s''.', ...
                upper(method), this.Specification);
        end
end

if ~nargout
    Hd = varargout{1};
    varargout = {};
    if this.NormalizedFrequency,
        inputs = {'NormalizedFrequency', 'On'};
    else
        inputs = {'Fs', this.Fs};
    end

    inputs = [inputs, {'DesignMask', 'on'}];

    h = fvtool(Hd, inputs{:});
    switch method
        case 'all'
            strs = designmethods(this, 'all', 'full');
        case {'allfir', 'alliir'}
            strs = designmethods(this, method(4:end), 'full');
        otherwise
            strs = {};
    end
    if ~isempty(strs), legend(h, strs{:}); end
end

% [EOF]
