function Hbest = minimizecoeffwlfir(this,Href,varargin) %#ok<INUSL>
%   This should be a private method

%   Author(s): R. Losada
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:14:24 $


fm = getfmethod(Href);

% Initialize
[Hbest,mrfflag] = optimizecoeffwl(Href,varargin{:});

if ~mrfflag,    
    Hd = copy(Hbest); % Copy in case something goes wrong in searchmicoeffwl.
    
    args.Hbest = Hd;
    args.Href = Href;
    try
        Hbest = searchmincoeffwl(fm,args,varargin{:});
    catch ME
        idx = findstr(ME.identifier,':');
        if strcmpi(ME.identifier(idx(end)+1:end),'unsupportedDesignMethod'),
            error(generatemsgid('useMaximizeStopband'),...
                ['MINIMIZECOEFFWL is not supported for these specifications.','\n',...
                'Consider using specifications that set the stopband attenuation.','\n',...
                'Alternatively, consider using MAXIMIZESTOPBAND for the current specifications.']);
        else
            % Do nothing, return Hbest from above
        end
    end
end
