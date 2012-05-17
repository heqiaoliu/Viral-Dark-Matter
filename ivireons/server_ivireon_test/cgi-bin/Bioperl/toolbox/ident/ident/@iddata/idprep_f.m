function [z,Ne,ny,nu,T,Name,Ncaps,errflag] = idprep_f(data,meflag,varargin)
%IDDATA/IDPREP_F  Prepares frequency domain data for parametric identification
%
%   [Z,Ne,Ny,Nu,T,Name,Ncaps,errflag] = IDPREP_F(Data,MEflag,NameIN)
%

%	L. Ljung 00-05-10
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.2.4.6 $  $Date: 2008/10/02 18:46:52 $

errflag = struct('identifier','','message','');
z = [];
Ncaps = [];
y = pvget(data,'OutputData');
u = pvget(data,'InputData');
freqs = pvget(data,'Radfreqs');
Ne = length(y);
ny = size(y{1},2);
nu = size(u{1},2);
Ts = pvget(data,'Ts');
T = Ts{1};
Name=data.Name;

if nargin>2
    Name = varargin{1};
end

if isnan(data)
    errflag.identifier = 'Ident:utility:idprepMissingDataInFreq';
    errflag.message = 'Frequency data containing NaNs cannot be used.';
    return
end

%{
if isempty(Name),
   Name = namein;
   data.Name=Name;
   assignin('caller',inputname(1),data);
end
%}

%ints = pvget(data,'InterSample');
%ints = ints{1};

if meflag && Ne>1
    errflag.identifier = 'Ident:general:idprepMultiExpData';
    errflag.message = 'This function does not accept multiple experiment data.';
    return
end

for ke=1:Ne
    if Ts{ke}>0%~strcmp(ints,'bl')
        farg = exp(i*freqs{ke}*Ts{ke});
    else
        farg = i*freqs{ke}; %% Need scaling?
    end
    z{ke} = [y{ke},u{ke},farg,farg]; %Include Ux0 and frequency argument
    Ncaps = [Ncaps,size(z{ke},1)];
    if any(any(isnan(z{ke}))')
        errflag.identifier = 'Ident:utility:idprepMissingData';
            errflag.message = 'Frequency data containing NaNs cannot be used.';
        return
    end
end

if meflag
    z = z{1};
    Ncaps = size(z,1);
end
