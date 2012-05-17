function [sys, stateName] = jacobian2ss(this,model,J,options,Ts)
%JACOBIAN2SS
%
% SYS = JACOBIAN2SS Obtains a linear model from the Jacobian structure.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.20 $ $Date: 2009/05/23 08:19:48 $

% Check for any non-real valued A,B,C,D
Anonfinite = isinf(J.A) | isnan(J.A);
Bnonfinite = isinf(J.B) | isnan(J.B);
Cnonfinite = isinf(J.C) | isnan(J.C);
Dnonfinite = isinf(J.D) | isnan(J.D);

if any(Anonfinite(:)) || any(Bnonfinite(:)) || ...
    any(Cnonfinite(:)) || any(Dnonfinite(:))
    [indx,unused] = find(Anonfinite); %#ok<NASGU>
    [~,indu] = find(Bnonfinite);
    [indy_c,unused] = find(Cnonfinite); %#ok<NASGU>
    [indy_d,unused] = find(Dnonfinite); %#ok<NASGU>
    blks = unique([get_param(J.Mi.OutputInfo(indy_c,1),'Parent');...
                   get_param(J.Mi.OutputInfo(indy_d,1),'Parent');...
                   get_param(J.Mi.InputInfo(indu,1),'Parent');...
                   J.stateBlockPath(indx)]); 
    blknames = '';           
    for ct = 1:numel(blks)
        blknames = sprintf('%s\n%s',blknames,regexprep(blks{ct},'\n',''));
    end
    ctrlMsgUtils.error('Slcontrol:linutil:InfBlockLinearization',model,char(blknames))
end

% Get the model sample rates and block dimensions
Tsx = J.Tsx;
Tsy = J.Tsy;
Ts_all = [Tsx;Tsy];
Tuq = unique(Ts_all(Ts_all >= 0));
Tuq(isinf(Tuq)) = [];

% Extract the upper parts of the LFT
a = J.A; b = J.B; c = J.C; d = J.D;
nx = size(a,1);

% Extract lower parts of the lft
E = J.Mi.E;
F = J.Mi.F;
G = J.Mi.G;
H = J.Mi.H;

% Get the state and state block names
stateName = J.stateName;
stateBlockPath = J.stateBlockPath;
OutputDelay = J.Mi.OutputDelay;

% Linearize without discrete states if the user desires, otherwise perform
% the discrete linearization if there are discrete states.
if (Ts == 0) && (strcmp(options.IgnoreDiscreteStates,'on') || ...
        (all(Tsx==0))) || (Ts == -1)

    % Remove discrete states
    if any(Tsx)
        ix = find(Tsx ~= 0);
        a(ix,:) = [];
        a(:,ix) = [];
        b(ix,:) = [];
        c(:,ix) = [];
        stateName(ix) = [];
        stateBlockPath(ix) = [];
    end
    
    % Close the LFT
    P = speye(size(d,1)) - d*E;
    Q = (G / P);
    a = a + ((b * E) / P) * c;
    b = b * (F + E * (P \ (d * F)));
    c = Q * c;
    d = H + Q * d * F;
else
    [ny,nu] = size(d);
    Tslist = [ Tuq ; Ts ];
    Eslow  = E;
    
    InputInfo = J.Mi.InputInfo(:,1);
    OutputInfo = J.Mi.OutputInfo(:,1);
    % Get all the input sample times
    Tsu = zeros(size(InputInfo));
    for ct = 1:numel(Tuq)
        blks = unique(OutputInfo(Tsy == Tuq(ct)));
        Tsu(ismember(InputInfo,blks)) = Tuq(ct);
    end
    
    for k=1:length(Tslist)-1
        % Start with the fastest rate
        ts_current = Tslist(k);
        ts_next    = min(Ts, Tslist(k+1));

        xix = find(Tsx == ts_current);

        % Find the indices of the blocks at the current sample rates these
        % indices correspond the outputs of the blocks
        ind_Tsy_current = find(Tsy==ts_current);
        ind_Tsu_current = find(Tsu==ts_current);

        % Close the fastest loops
        [ix,jx,px] = find(Eslow);
        ux1 = ismember(ix, ind_Tsu_current);
        ux2 = ismember(jx, ind_Tsy_current);
        ux = ux1 & ux2;
        Efast = sparse(ix(ux),jx(ux),px(ux),nu,ny);

        % And mark them as closed (remove them from interconnection matrix)
        Eslow = Eslow - Efast;
        P = speye(ny) - d*Efast;

        % Update the block outputs to indicate the rate conversion
        Tsy(ind_Tsy_current) = ts_next;
        Tsu(ind_Tsu_current) = ts_next;
        
        % But leave the matrices "full-sized" for later connection
        c = P \ c;
        d = P \ d;
        a = a + b * Efast * c;
        b = b * (speye(nu) + Efast*d);
        
        % Find the IO channels that can be pruned.  These are:
        % 1. Block outputs that are not connected to any linearization 
        %    output.
        %       AND
        %    Block outputs that are not connected to any block inputs of a
        %    different sample time.
        % 2. Block inputs that are not connected to any linearization input.
        %       AND
        %    Block inputs that are not connected to any source block with a 
        %    different sample time.
        [~,~,~,~,signalmask] = smreal_lft(linutil,a,b,c,d,Eslow,F,G);               
        bout_keep_logic_ind = signalmask(nx+(1:ny));       
        bin_keep_logic_ind = signalmask(nx+ny+(1:nu));
        b = b(:,bin_keep_logic_ind); d = d(:,bin_keep_logic_ind);
        c = c(bout_keep_logic_ind,:); d = d(bout_keep_logic_ind,:);
        Eslow = Eslow(bin_keep_logic_ind,:); F = F(bin_keep_logic_ind,:);
        Eslow = Eslow(:,bout_keep_logic_ind); G = G(:,bout_keep_logic_ind);
        OutputDelay = OutputDelay(bout_keep_logic_ind);
        OutputInfo = OutputInfo(bout_keep_logic_ind);
        InputInfo = InputInfo(bin_keep_logic_ind);
        Tsu = Tsu(bin_keep_logic_ind);
        Tsy = Tsy(bout_keep_logic_ind);

        % Re-compute the number of inputs and outputs since this has changed
        % from the pruning.
        [ny,nu] = size(d);
        
        % if the target rate is the slowest rate we are done
        if ts_current ~= ts_next

            % Otherwise use c2d/d2d/d2c to reach the next rate
            atmp = full(a(xix,xix));

            % Find the input and output channels that
            % correspond the states that are being converted
            indu = find(any(b(xix,:),1));
            indy = find(any(c(:,xix)',1) | (OutputDelay' ~= 0));
            btmp = full(b(xix,indu));
            ctmp = full(c(indy,xix));
            dtmp = full(d(indy,indu));
            sysold = ss(atmp,btmp,ctmp,dtmp,ts_current,'OutputDelay',OutputDelay(indy));
                        
            % Convert the system sample rate
            sysnew = utRateConversion(this,sysold,ts_next,options);
            
            if ~strcmp(options.RateConversionMethod,'zoh')
                % Remove any statenames that may have been used in the
                % conversion for Tustin routines
                for ct = 1:length(xix)
                    stateName{xix(ct)} = '?';
                    stateBlockPath{xix(ct)} = '?';
                end
            end
            
            if length(sysold.a) ~= length(sysnew.a)
                % Expand the number of states to account for states that have been added
                deltanstates = length(sysnew.a)-length(sysold.a);
                nx_iter = size(a,1);
                laststate = xix(end);
                % Insert rows into the a matrix
                a = [a(1:laststate,:);zeros(deltanstates,nx_iter);a(laststate+1:nx_iter,:)];
                % Insert columns into the a matrix
                a = [a(:,1:laststate),zeros(nx_iter+deltanstates,deltanstates),a(:,laststate+1:nx_iter)];
                % Insert rows into the b matrix
                b = [b(1:laststate,:);zeros(deltanstates,nu);b(laststate+1:nx_iter,:)];
                % Insert columns into the c matrix
                c = [c(:,1:laststate),zeros(ny,deltanstates),c(:,laststate+1:nx_iter)];
                % Insert rows into the StateName field
                EmptyStates = cell(deltanstates,1);
                for ct = 1:deltanstates
                    EmptyStates{ct} = '?';
                end
                if laststate == nx_iter;
                    stateName = {stateName{:},EmptyStates{:}};
                    stateBlockPath = {stateBlockPath{:},EmptyStates{:}};
                else
                    stateName = {stateName{1:laststate},EmptyStates{:},stateName{laststate+1:nx_iter}};
                    stateBlockPath = {stateBlockPath{1:laststate},EmptyStates{:},stateBlockPath{laststate+1:nx_iter}};
                end
                % Insert rows into the Tsx vector
                Tsx = [Tsx(1:laststate);zeros(deltanstates,1);Tsx(laststate+1:nx_iter)];
                
                % Update the xix and nix vectors
                xix = [xix;(1:deltanstates)'+laststate]; %#ok<AGROW>
                nx = size(a,1);
            end
            [a(xix,xix),b(xix,indu),c(indy,xix),d(indy,indu)] = ssdata(sysnew);
            % Store the output delay
            OutputDelay(indy) = sysnew.OutputDelay;
        end
        Tsx(xix) = ts_next;
    end
    
    % Close the remaining loops if they are any still open
    if any(any(Eslow))
        % Close the final loop if needed
        P = speye(ny) - d*Eslow;
        c = P \ c;
        d = P \ d;
        a = a + b * Eslow * c;
        b = b * (speye(nu) + Eslow*d);
    end
    
    % Apply analysis input and output selection
    b = b * F;
    c = G * c;
    d = H + G * d * F;
end

% Create the linear model
sys = ss(full(a),full(b),full(c),full(d),Ts,'StateName',stateBlockPath,...
                'OutputDelay',full(G*OutputDelay));

if strcmp(options.BlockReduction,'on')
    % Call sminreal to remove any states lost during discretization.
    [sys,xkeep] = sminreal(sys);
    stateName(~xkeep) = [];
end
