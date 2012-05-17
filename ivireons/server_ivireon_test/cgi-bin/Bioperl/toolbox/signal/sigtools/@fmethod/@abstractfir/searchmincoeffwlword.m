function Hbest = searchmincoeffwlword(this,args,minordspec,designargs,varargin) %#ok<INUSL>
%SEARCHMINCOEFFWLWORD Find min coeff word length filter when order
%specified.
%   This should be a private method.
%
%   If args doesn't have wl field: search for global minimum.
%
%   If args has wl field: search for a filter with coeff wordlength of at
%                         most wl.

%   Author(s): R. Losada
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:16:36 $


wlflag = false;
if isfield(args,'wl'),
    wlflag = true;
end

Hbest  = args.Hbest;
bestwl = Hbest.CoeffWordLength;

Href = args.Href;
fd   = getfdesign(Href);

minwlargs = wloptiminputparse(Href,varargin{:});
Aptol = minwlargs.Apasstol;
Astol = minwlargs.Astoptol;

% Coarse loop
Apbest  = fd.Apass;
Astbest = fd.Astop;
iters = 20;
Ap  = linspace(fd.Apass,.1*fd.Apass,iters);
Ast = linspace(fd.Astop,fd.Astop+iters,iters);
Astdelta = Ast(2)-Ast(1);
done = false;
search();

if ~done,
    % Fine loop    
    Ap  = linspace(Apbest,Apbest,iters);
    Ast = linspace((fd.Astop+Astbest)/2,Astbest+Astbest-(fd.Astop+Astbest)/2,iters);
    Astdelta_fine = Ast(2)-Ast(1);
    if Astdelta_fine < Astdelta,
        % Fine loop provides best result for instance for the following case:
        % f = fdesign.lowpass('N,Fc,Ap,Ast',80);h = design(f,'equiripple');hq = h.minimizecoeffwl
        search();
    end
end

if ~done && wlflag,
    % Reach iteration limit
    error(generatemsgid('coeffWlIterLimit'),...
        'Unable to design filter to meet specifications with given wordlength.');
end

setfdesign(Hbest,fd);

    function search

        for k = 2:iters, % Start with k=2, don't repeat baseline case
            f = copy(fd);
            f.Apass = Ap(k);
            f.Astop = Ast(k);
            h = design(f,designargs{:});

            
            hq = optimizecoeffwl(h,'Apasstol',Aptol+fd.Apass-Ap(k),...
                'Astoptol',Astol+Ast(k)-fd.Astop,...
                'noiseShapeNorm',minwlargs.noiseShapeNorm,...
                'noiseShaping',minwlargs.noiseShaping,...
                'NTrials',minwlargs.NTrials);
            
            % Set the Fpass, Fstop from floating-point design and set
            % original ripples. This is to verify that quantized filter
            % meets spec
            m = measure(h);
            ft = copy(fd);
            ft.Specification = minordspec;
            ft.Fpass = m.Fpass;
            ft.Fstop = m.Fstop;                        
            
            if isspecmet(hq,ft), % In some cases spec is not met
                if wlflag
                    % Constrain wl case
                    done = hq.CoeffWordLength<=args.wl;
                    if done,
                        Hbest = hq;
                        break; % Exit for loop
                    end
                else
                    if hq.CoeffWordLength < bestwl,
                        bestwl = hq.CoeffWordLength;
                        Hbest = hq;
                        Apbest = Ap(k);
                        Astbest = Ast(k);
                    elseif hq.CoeffWordLength == bestwl && Ast(k) < Astbest,
                        Hbest = hq;
                        Apbest = Ap(k);
                        Astbest = Ast(k);
                    end
                end
            end
        end
        
    end

end

% [EOF]
