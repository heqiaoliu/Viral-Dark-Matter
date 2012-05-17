function Hbest = searchmincoeffwlmin(this,args,varargin)
%SEARCHMINCOEFFWL Search for min. coeff wordlength.
%   This should be a private method.
%
%   If args doesn't have wl field: search for global minimum.
%
%   If args has wl field: search for a filter with coeff wordlength of at
%                         most wl.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:36:44 $

wlflag = false;
if isfield(args,'wl'),
    wlflag = true;
end

Hbest  = args.Hbest;
bestwl = Hbest.CoeffWordLength;

Href = args.Href;
fd   = getfdesign(Href);

search();

    function search
        
        % Record filter order
        N = length(Hbest.Numerator)-1; % Don't use order() because of halfbands
        % with zero coeffs at the end-points
        
        % Convert minimum order spec into spec where order is specified
        [fspecs dm dopts Nstep] = convert2specword(this,getcurrentspecs(fd),N);
        
        done = false;
        count = 0;
        while ~done
            count = count + 1;
            
            % Increment filter order
            fspecs.FilterOrder = fspecs.FilterOrder+Nstep;
            h = feval(dm,fspecs,dopts{:});
            Href.Numerator = h.Numerator*nominalgain(fd); % In case design is an interpolator
            setfdesign(Href,fd);
            setfmethod(Href,this);
            
            % Try design with noise shaping to see if we meet specs
            hq = optimizecoeffwl(Href,varargin{:});
            if isspecmet(hq), 
                if wlflag,
                    % Constrain wl
                    done = hq.CoeffWordLength<=args.wl;
                    if done,
                        Hbest = hq;
                    else
                        if count == 20,
                            break; % Exit while loop, done still == false
                        end
                    end
                else
                    if hq.CoeffWordLength < bestwl,
                        bestwl = hq.CoeffWordLength;
                        Hbest = hq;
                    elseif hq.CoeffWordLength > bestwl
                        done = true;
                    else
                        if count == 20,
                            done = true;
                            break; % Exit while loop, done still == false
                        end
                    end
                end
            end
            
        end
        
        if ~done,
            % Reach iteration limit
            error(generatemsgid('coeffWlIterLimit'),...
                ['Unable to design filter to meet specifications with given wordlength. ', ...
                'Maximum order tried: ', num2str(fspecs.FilterOrder)]);
        end
    end
end





% [EOF]
