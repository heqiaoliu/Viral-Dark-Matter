function [z,Ne,ny,nu,T,Name,Ncaps,errflag,ynorm] = idprep(data,meflag,varargin)
%IDDATA/IDPREP  Prepares data for parametric identification
%
%   [Z,Ne,Ny,Nu,T,Name,Ncaps,errflag] = IDPREP(Data,MEflag,NameIN)


%	L. Ljung 00-05-10
%	Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.10.4.6 $  $Date: 2008/07/14 17:06:38 $

errflag = struct('identifier','','message','');
z = [];
Ncaps = [];
ynorm = 0;
y = data.OutputData;
u = data.InputData;
Ne = length(y);
ny = size(y{1},2);
nu = size(u{1},2);
Ts = data.Ts;
T = Ts{1};
Name = data.Name;

if nargin>2
    Name = varargin{1};
end

if isnan(data)
    errflag.identifier = 'Ident:general:idprepMissingData';
    errflag.message = ['Data contains NaNs which represent missing values. ',...
        'Use the "misdata" command to fill in the missing values before using.'];
      return
end

%ints = data.InterSample;
if meflag && Ne>1
    errflag.identifier = 'Ident:general:idprepMultiExpData';
    errflag.message = 'Use of multi-experiment data is not supported for this operation.';
    return
end
if meflag
    z=[y{1},u{1}];
    Ncaps = size(z,1);
else
    for ke=1:Ne
        ynorm = norm(y{ke},'fro')^2 + ynorm;
        z{ke} = [y{ke},u{ke}];
        Ncaps = [Ncaps,size(z{ke},1)];
        if isempty(Ts{ke})
            errflag.identifier = 'Ident:general:idprepNonUniformDataTs';
            errflag.message = 'The data must be uniformly sampled.';
            return
        elseif Ts{ke}~=T
            errflag.identifier = 'Ident:general:idprepNonUniqueDataTs';
            errflag.message = 'The sampling intervals of all the data experiments must have the same value.';
            return
        end

        %%LL%% Same intersample
        %%LL%% Reduce periodic

        if any(any(isnan(z{ke}))')
            errflag.identifier = 'Ident:general:idprepMissingData';
            errflag.message = ['Data contains NaNs which represent missing values. ',...
                'Use the "misdata" command to fill in the missing values before using.'];
            return
        end
    end
end
ynorm = sqrt(ynorm/sum(Ncaps));
