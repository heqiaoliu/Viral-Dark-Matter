function Hd = constraincoeffwlfir(this,Href,WL,varargin) %#ok<INUSL>
%CONSTRAINCOEFFWLFIR Constrain coefficient wordlength.
%   This should be a private method

%   Author(s): R. Losada
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:14:23 $


fm = getfmethod(Href);

% Try design with noise shaping to see if we meet specs
Hd = optimizecoeffwl(Href,varargin{:});
done = Hd.CoeffWordLength<=WL;


if ~done
    Hbest = Hd;
    
    args.Hbest = Hbest;
    args.Href  = Href;
    args.wl    = WL;
    try
        Hd = searchmincoeffwl(fm,args,varargin{:});
    catch ME
        idx = findstr(ME.identifier,':');
        if strcmpi(ME.identifier(idx(end)+1:end),'unsupportedDesignMethod'),
            error(generatemsgid('constraincoellwlNotSupported'),...
                ['CONSTRAINCOEFFWL is not supported for these specifications.','\n',...
                'Consider using specifications that set the stopband attenuation.','\n',...
                'Alternatively, consider using MAXIMIZESTOPBAND for the current specifications.']);
        else
            throwAsCaller(ME);
        end
    end
end

