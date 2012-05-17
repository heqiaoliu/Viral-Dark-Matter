function args = postprocessminorderargs(this,args,hspecs)
%POSTPROCESSMINORDERARGS Test that the spec is met.
%   firpmord sometimes under estimate the order e.g. when the transition
%   band is near f = 0 or f = fs/2. POSTPROCESSMINORDERARGS uses
%   measurements to adjust the filter order until the spec is met.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/12/05 02:24:25 $

extraargs = {{this.DensityFactor}};
Nstep = 1;

designfcn = getdesignfunction(this);
if isequal(designfcn,@firgr)    
    if this.MinPhase
        extraargs = [extraargs, {'minphase'}];
        Nstep = 2;
    elseif isprop(this,'MaxPhase') && this.MaxPhase
        extraargs = [extraargs, {'maxphase'}];
        Nstep = 2;
    end
    
    if isminordereven(this),
        args{1}{1} = 'mineven';
        % Make sure that the initial order is even.
        if rem(args{1}{2}, 2) == 1
            args{1}{2} = args{1}{2}-1;
        end
        Nstep = 2;
    elseif isminorderodd(this),
        args{1}{1} = 'minodd';
        % Make sure that the initial order is odd.
        if rem(args{1}{2}, 2) == 0
            args{1}{2} = args{1}{2}-1;
        end
        Nstep = 2;
        if isa(this,'fdfmethod.eqriphpmin'),
            args{end+1} = 'h';
        end
    end
else   
    args{1} = max(args{1},3);
end

% Suppress repetitive warnings that can be thrown by the design fcns
w = warning('off'); %#ok<WNOFF>

% Use measurements to adjust the filter order until the spec is met.
[varargout{1:nargout}] = designfcn(args{:}, extraargs{:});
cache = args;
hfilter  = dfilt.dffir(varargout{1});
if ~iskaisereqripminspecmet(this,hfilter,hspecs)
    done = false;
    count = 0;
    args{1} = order(hfilter);
    while ~done && count < 25
        try
            % try/catch is necessary because the design function (e.g.
            % firgr) may not converge when the filter order is increased.
            args = privupdateargs(this,args,Nstep);
            [varargout{1:nargout}] = designfcn(args{:}, extraargs{:});
            hfilter.Numerator = varargout{1};
            count = count +1;
            if iskaisereqripminspecmet(this,hfilter,hspecs), done = true; end
        catch ME, %#ok<NASGU>
            done = true;
            args = cache; % Return original design if spec is not met
        end
    end
else
    done = true;
end

warning(w);

if ~done,
    args = cache; % Return original design if spec is not met
end
    


