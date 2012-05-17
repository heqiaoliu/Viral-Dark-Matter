function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDARX models.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation
%   operation
%         MOD = [MOD1 , MOD2 , ...]
%
%   This operation amounts to appending the inputs and
%   adding the outputs of the models MOD1, MOD2,...
%
%   In general IDARX models will be converted to IDSS models.
%   If all models MODk have the same A-polynomial, the result is
%   returned as an IDARX model.
%   If all models MODk are impulse response models with the same
%   time variable, the result is also returned as an IDARX, Impulse
%   Response model.
%
%   See also VERTCAT,  IDMODEL.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2008/10/02 18:46:29 $

if nargin==1,
    sys = varargin{1};
    return
end

%first deal with the case of all impulse responses with same time:
if isaimp(varargin{1})
    ii = 1;
    ny = size(varargin{1},'ny');
    ut = pvget(varargin{1},'Utility');
    time = ut.impulse.time;
    for kj=2:nargin
        if isaimp(varargin{kj})
            utj = pvget(varargin{kj},'Utility');
            ti = utj.impulse.time;
        end
        ii = ii&&isaimp(varargin{kj})&&(ny==size(varargin{kj},'ny'))&&length(ti)==length(time)...
            &&all(time==ti);
    end
    if ii % Then concatenate as impulse response
        sys = varargin{1};
        ut = pvget(sys,'Utility');
        for kj = 2:nargin
            sysj = varargin{kj};
            try
                sys.idmodel = [sys.idmodel , sysj.idmodel];
            catch E
                throw(E)
            end
            
            utj = pvget(sysj,'Utility');
            B = pvget(sys,'B');
            dB = ut.impulse.dB;
            dBB = utj.impulse.dB;
            dBstep = ut.impulse.dBstep;
            dBBstep = utj.impulse.dBstep;
            [ny,nu,Nb]=size(B);
            BB = pvget(sysj,'B');
            [nny,nnu,NNb]=size(BB);
            BBB = zeros(ny,nu+nnu,max(Nb,NNb));
            dBBB = BBB;
            dBBBstep = BBB;
            BBB(:,1:nu,1:Nb)=B;
            BBB(:,nu+1:nu+nnu,1:NNb)=BB;
            dBBB(:,1:nu,1:Nb)=dB;
            dBBB(:,nu+1:nu+nnu,1:NNb)=dBB;
            dBBBstep(:,1:nu,1:Nb)=dBstep;
            dBBBstep(:,nu+1:nu+nnu,1:NNb)=dBBstep;
            ut.impulse.B = BBB;
            ut.impulse.dB = dBBB;
            ut.impulse.dBstep = dBBBstep;
            sys = pvset(sys,'B', BBB,'Utility',ut);
        end
        return
    end
end

% Now deal with the case that all A are the same:
sys = idarx(varargin{1});
A = pvget(sys,'A');
yna = pvget(sys,'OutputName');
ac = 1;
for kj =2:nargin
    
    Aj = pvget(idarx(varargin{kj}),'A');
    ac = ac&&all(size(A)==size(Aj))&&all(A(:)==Aj(:));
end
if ac % Then concatenate as IDARX
    for kj = 2:nargin
        P = pvget(sys.idmodel,'CovarianceMatrix');
        
        if isempty(P)||ischar(P)
            noP = 1;
        else
            noP = 0;
        end
        if ~noP
            par = pvget(sys.idmodel,'ParameterVector');
            l2 = length(par);
            sys1 = parset(sys,[1:l2]');
            [A1,B1] = arxdata(sys1); %% This is for tracking elements
            %% in the covariance matrix
        end
        
        sysj = idarx(varargin{kj});
        try
            sys.idmodel = [sys.idmodel , sysj.idmodel];
        catch E
            throw(E)
        end
        
        B = pvget(sys,'B');
        [ny,nu,Nb]=size(B);
        BB = pvget(sysj,'B');
        [nny,nnu,NNb]=size(BB);
        BBB = zeros(ny,nu+nnu,max(Nb,NNb));
        BBB(:,1:nu,1:Nb)=B;
        BBB(:,nu+1:nu+nnu,1:NNb)=BB;
        
        sys = pvset(sys,'B', BBB);
        %end
        if ~noP
            Pj = pvget(sysj.idmodel,'CovarianceMatrix');
            if isempty(Pj)||ischar(Pj)
                noP = 1;
            else
                P = [[P,zeros(size(P,1),size(Pj,2))];[zeros(size(Pj,1),size(P,2)),Pj]];
                parj = pvget(sysj.idmodel,'ParameterVector');
                l1 = l2 + 1;
                l2 = l1 + length(parj);
                sysj1 = parset(sysj,[l1:l2]');
                [a1,b1] = arxdata(sysj1);
                [Ny,Nu,Nb]=size(B1);
                [ny,nu,nb] = size(b1);
                if Nb>nb
                    bb1=zeros(ny,nu,Nb);
                    bb1(:,:,1:nb)=b1;
                    b1 = bb1;
                elseif nb>Nb
                    BB1 = zeros(Ny,Nu,nb);
                    BB1(:,:,1:Nb) = B1;
                    B1 =BB1;
                end
                B1 = [B1,b1];
            end
        end
        
        % Create result
        cov =[];
        if ~noP
            sys1 = pvset(sys,'A',A1,'B',B1);
            par = pvget(sys1.idmodel,'ParameterVector');
            if length(P)>=max(par)
                cov = P(par,par);
            end
        end
        %% Hidden models
        utj = pvget(sysj,'Utility');
        ut = pvget(sys,'Utility');
        try
            idpj = utj.Idpoly;
            idp = ut.Idpoly;
            if isempty(idpj)||isempty(idp)
                idp =[];
            else
                idp = [idp,idpj];
            end
        catch
            idp = [];
        end
        ut.Idpoly = idp;
        if isfield(ut,'impulse'),
            ut = rmfield(ut,'impulse');
        end
        sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',cov,'Utility',ut);
        
    end
    return
end

% Now, in the case of different A's the result cannot be IDARX
ctrlMsgUtils.warning('Ident:combination:idarxHorzcat1')
for kj = 1:nargin
    varargin{kj} = idss(varargin{kj});
end
sys = horzcat(varargin{:});
