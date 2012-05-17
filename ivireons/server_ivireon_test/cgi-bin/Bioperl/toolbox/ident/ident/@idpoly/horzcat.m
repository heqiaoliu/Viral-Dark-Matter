function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDPOLY models.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation
%   operation
%         MOD = [MOD1 , MOD2 , ...]
%
%   This operation amounts to appending the inputs and
%   adding the outputs of the models MOD1, MOD2,...
%
%   The models are first converted to Output error type,
%   so noise properties are not covered. Also, the covariance
%   information is lost.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.7 $  $Date: 2009/12/22 18:53:49 $

%{
ni = nargin;
for i=1:ni
    sizes = size(varargin{i});
end
%}

nsys = length(varargin);
if nsys==0,
    sys = ss;  
    return
end

% Initialize output SYS to first input system
sys = idpoly(varargin{1});

[A,B,~,~,F] = polydata(sys,1);
if ~isempty(F)
   for k = 1:size(F,1);
      F1(k,:) = conv(A,F(k,:));
   end
   F = F1;
end
TS = pvget(sys,'Ts');

CellFormat = pvget(sys,'BFFormat');

%% Only dealing with output error for the concatenation
% Concatenate remaining input systems
for j=2:nsys,
    sysj = idpoly(varargin{j});
    [a,b,~,~,f]= polydata(sysj,1);
    ts = pvget(sysj,'Ts');
    if ts ~= TS
        ctrlMsgUtils.error('Ident:combination:concatTsMismatch')
    end

    if ~isempty(f)
       for k = 1:size(f,1);
          f1(k,:) = conv(a,f(k,:));
       end
       f = f1;
    end
    
    try
        sys.idmodel = [sys.idmodel , sysj.idmodel];
    catch E
        throw(E)
    end
    [NU,NB] = size(B);[nu,nb]=size(b);
    B1 = zeros(NU+nu,max(NB,nb));
    if ts>0
        B1(1:NU,1:NB)= B;
        B1(NU+1:end,1:nb) = b;
    else
        B1(1:NU, max(nb,NB)-NB+1:end)=B;
        B1(NU+1:end,max(nb,NB)-nb+1:end)=b;
    end
    B = B1;
    [NU,NF] = size(F);[nu,nf]=size(f);
    F1 = zeros(NU+nu,max(NF,nf));
    if ts>0
        F1(1:NU,1:NF)= F;
        F1(NU+1:end,1:nf) = f;
    else

        F1(1:NU, max(nf,NF)-NF+1:end)=F;
        F1(NU+1:end,max(nf,NF)-nf+1:end)=f;
    end
    F = F1;
    CellFormat = max(CellFormat,pvget(sysj,'BFFormat')); % let double format win
end

% Create result
sys = pvset(sys,'a',1,'b',B,'c',1,'d',1,'f',F,'CovarianceMatrix',[],...
    'BFFormat',CellFormat);
