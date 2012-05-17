function D = utSISOLFT(D,C)
% Computes LFT(D,DIAG(C1,...,CN)) where each Cj is SISO.
% Optimized for SISO Tool use.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:57 $

% Number of C's
nC = length(C);

try
    if localHasDelay(C)
        % Delays in C use ssdata/lft command to close LFT
        D = localComputeLFT(D,C);
    else
        % Assumes no delays in C's
        [nYandC,nUandC] = iosize(D);
        ny = nYandC-nC;
        nu = nUandC-nC;
        
        % Fold in I/O delays associated with I/Os which will be closed
        Din = D.Delay.Input;
        Din(1:nu,:) = 0;
        Dout = D.Delay.Output;
        Dout(1:ny,:) = 0;
        D = utFoldDelay(D,Din,Dout);
        
        [rs,cs] = size(D.d);
        nd = length(D.Delay.Internal);% rs-nYandC or rc-nUandC;
        
        % Shift IO channels so that C's are at the bottom
        idxIn = [1:nu,nUandC+(1:nd),nu+(1:nC)];
        idxOut = [1:ny,nYandC+(1:nd),ny+(1:nC)];
        
        a = D.a;
        b = D.b(:,idxIn);
        c = D.c(idxOut,:);
        d = D.d(idxOut,idxIn);
        e = D.e;
        
        % Close each SISO loop successively
        for ct=nC:-1:1
            ac = C(ct).a;
            bc = C(ct).b;
            cc = C(ct).c;
            dc = C(ct).d;
            ec = C(ct).e;
            t = 1-d(rs,cs)*dc;
            if t==0
                ctrlMsgUtils.error('Controllib:general:UnexpectedError','Algebraic loop')
            end
            b2 = b(:,cs);
            c2 = c(rs,:);
            d21 = d(rs,1:cs-1);
            d12 = d(1:rs-1,cs);
            dct = dc/t;
            e = localutBlkDiagE(e,ec,a,ac);
            a = [a+b2*(dct*c2) , b2*(cc/t) ; bc*(c2/t) , ac+bc*((d(rs,cs)/t)*cc)];
            b = [b(:,1:cs-1) + b2*(dct*d21) ; bc*(d21/t)];
            c = [c(1:rs-1,:) + (d12*dct)*c2 , (d12/t)*cc];
            d = d(1:rs-1,1:cs-1) + d12*dct*d21;
            
            % Decrement sizes
            rs = rs-1;
            cs = cs-1;
        end
        
        % Return closed-loop model
        D.a = a;
        D.b = b;
        D.c = c;
        D.d = d;
        D.e = e;
        D.Delay.Input = D.Delay.Input(1:nu);
        D.Delay.Output = D.Delay.Output(1:ny);
        % Note: Internal Delay did not change.
        if ~isempty(D.StateName)
           D.StateName(end+1:size(a,1),:) = {''};
        end
        if ~isempty(D.StateUnit)
           D.StateUnit(end+1:size(a,1),:) = {''};
        end
        D.Scaled = false;
    end
    
catch ME  %#ok<NASGU>
    % Algebraic loop encountered, use ssdata/lft command to close LFT
    D = localComputeLFT(D,C);
end



function e = localutBlkDiagE(e1,e2,a1,a2)
%Revisit Copied from utBlkDiagE
if isempty(e1) && isempty(e2)
    % Quick handling of non-descriptor case
    e = [];
else
    if isempty(e1)
        e1 = eye(size(a1));
    end
    if isempty(e2)
        e2 = eye(size(a2));
    end
    ne1 = size(e1,1);
    ne2 = size(e2,2);
    e = [e1 zeros(ne1,ne2);zeros(ne2,ne1) e2];
end


function D = localComputeLFT(D,C)
% Use ssdata/lft command to close LFT
% Create diagonal compensator block because compensators are passed in as a
% vector
nC = length(C);
Cdiag = C(1);
for ct = 2:nC
    Cdiag = append(Cdiag,C(ct));
end
[Dout,Din]=iosize(D);
sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
D = lft(D,Cdiag,Din-nC+1:Din,Dout-nC+1:Dout,1:nC,1:nC);


function boo = localHasDelay(D)
% Check if any D has delay
if isscalar(D)
    boo = hasdelay(D);
else
    boo = false;
    for ct=1:numel(D)
        boo = boo || hasdelay(D(ct));
        if boo,
            break
        end
    end
end
