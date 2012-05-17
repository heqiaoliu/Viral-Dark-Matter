function [z,Ne,ny,nu,T,Name,Ncaps,errflag,ynorm] = idprep_fp(data,meflag,varargin)
%IDDATA/IDPREP  Prepares data for parametric identification
%
%   [Z,Ne,Ny,Nu,T,Name,Ncaps,errflag] = IDPREP(Data,MEflag,NameIN)

%	L. Ljung 00-05-10
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.2.4.4 $  $Date: 2008/07/14 17:06:40 $

errflag = struct('identifier','','message','');
z = [];
Ncaps = [];
y = pvget(data,'OutputData');
u = pvget(data,'InputData');
Ne = length(y);
ny = size(y{1},2);
nu = size(u{1},2);
Ts = pvget(data,'Ts');
T = Ts{1};
ynorm = [];
Name = data.Name;
if nargin>2
    Name = varargin{1};
end

if isnan(data)
    errflag.identifier = 'Ident:utility:idprepMissingDataInFreq';
    errflag.message = 'Frequency data containing NaNs cannot be used.';
    return
end

%ints = data.InterSample;
if meflag && Ne>1
    errflag.identifier = 'Ident:general:idprepMultiExpData';
    errflag.message = 'This command does not accept multiple experiment data.';
    return
end

farg = pvget(data,'Argument');

%om = pvget(data,'SamplingInstants');
ynorm = 0;
if meflag
    z = [y{1},u{1}];
    Ncaps = size(z,1);
else
    for ke = 1:Ne
        %        if Ts{ke}==0
        %            efre  = i*om{ke};
        %        else
        %            efre = exp(i*om{ke}*Ts{ke});
        %        end
        z{ke} = [y{ke},u{ke},farg{ke}]; % %%LL note now freq last!
        ynorm = norm(y{ke},'fro')^2 + ynorm;
        Ncaps = [Ncaps,size(z{ke},1)];
        if isempty(Ts{ke}) || Ts{ke}~=T
            errflag.identifier = 'Ident:general:idprepNonUniformDataTs';
            errflag.message = 'This command requires equally sampled data in each experiment.';
            return
        end

        %%LL%% Same intersample
        %%LL%% Reduce periodic

        if any(any(isnan(z{ke}))')
            errflag.identifier = 'Ident:utility:idprepMissingDataInFreq';
            errflag.message = 'Frequency data containing NaNs cannot be used.';
            return
        end
    end
end
ynorm = sqrt(ynorm/sum(Ncaps));
