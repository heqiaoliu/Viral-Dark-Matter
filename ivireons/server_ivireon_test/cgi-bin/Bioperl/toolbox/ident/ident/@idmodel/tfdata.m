function [num,deno,dnum,dden]=tfdata(th,iu)
%IDMODEL/TFDATA  Transforms IDMODEL model objects to transfer functions.
%
%   [NUM,DEN] = TFDATA(MODEL) returns the numerator(s) and denominator(s)
%   of the model object MODEL.  For a transfer function with NY
%   outputs and NU inputs, NUM and DEN are NY-by-NU cell arrays such that
%   NUM{I,J} (note the curly brackets) specifies the transfer
%   function from input J to output I.
%
%   [NUM,DEN,SDNUM,SDDEN] = TFDATA(MODEL) also returns the standard
%   deviations of the numerator and denominator coefficients.
%   Other properties of MODEL can be accessed with GET or by direct structure-like
%   referencing (e.g., MODEL.Ts.)
%
%   If MODEL is a time series (NU=0) the transfer functions from
%   the (unnormalized, see HELP NOISECNV) noise source e to the
%   outputs y are returned. There are NY-by-NY such transfer functions.
%
%   To obtain the noise responses for a system with input, use
%       [NUM,DEN] = TFDATA(MODEL('noise'))
%
%   Use NOISECNV to convert the noise sources to measured channels, with options
%   to include normalizations of noise variances.
%
%   For a SISO model MODEL, the syntax
%       [NUM,DEN] = TFDATA(MODEL,'v')
%   returns the numerator and denominator as row vectors rather than
%   cell arrays.
%
%   See also IDMODEL/SSDATA, IDMODEL/ZPKDATA, IDMODEL/POLYDATA, IDMODEL/FREQRESP
%   and NOISECNV.

%   L. Ljung 10-2-90
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.2.4 $  $Date: 2009/10/16 04:55:29 $

if nargin<2
    iu='';
end
Nu = size(th,'Nu');
if Nu>0
    th = th(:,'m'); %To avoid mixing dynamics
end
if isa(th,'idproc')
    if Nu>1
        [num,deno,dnum,dden]=tfdatauax(th,iu,nargout);
        return
    end
end
Ts =pvget(th,'Ts');
[a,b1,c,d1,k]=ssdata(th);
if isempty(a) && isempty(d1)
    num =[]; deno = []; dnum =[]; dden =[];
    return
end

[ny,nu]=size(d1);
Nu = nu;
%[mc,nc] = size(c);
%dk = eye(mc);
den = poly(a);
if nu == 0
    b = k;
    d = eye(ny);
    nu = ny;
else
    b = b1;
    d = d1;
end

den = den.*(abs(den)>eps); %strip spurious numbers - check tolerance
for ku=1:nu
    for ky=1:ny
        num1  = poly(a-b(:,ku)*c(ky,:)) + (d(ky,ku) - 1) * den;
        num1 = num1.*(abs(num1)>eps); %strip spurious numbers - check tolerance
        if Ts>0
            nnn = find(abs(num1 )>100*eps, 1, 'last' );
            nnd = find(abs(den)>100*eps, 1, 'last' );
        else
            nnn = length(num1); nnd = length(den);
        end
        if isempty(nnn)
            deno{ky,ku} = 1;
            num{ky,ku} = 0;
        else
            deno{ky,ku} = den(1:max(nnn,nnd));
            num{ky,ku} = num1(1:max(nnn,nnd));
        end
    end
end
if ~isempty(iu) && strcmpi(iu,'v') && Nu<=1
    num = num{1,1}; deno = deno{1,1};
end
if nargout<3
    return
end
if Nu>0
    mp = idpolget(th,[],'b');
else
    mp = idpolget(th,[],'b');
end
if isempty(mp)
    dnum = []; dden =[];
    return
end

for ky = 1:ny
    if ~iscell(mp),mp={mp};end
    [~,~,dnum1,dden1] = tfdata(mp{ky}(1,1:nu));
    dnum(ky,:) = dnum1;
    dden(ky,:) = dden1;
end
if ~isempty(iu) && strcmpi(iu,'v') && Nu==1
    dnum = dnum{1,1}; dden = dden{1,1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [num,deno,dnum,dden]=tfdatauax(th,vec,na)
nu = size(th,'nu');
for ku = 1:nu
    if na < 3
        [num1,deno1] = tfdata(th(ku));

        num(:,ku)=num1;
        deno(:,ku)=deno1;

        dnum={};dden={};
    else
        [num1,deno1,dnum1,dden1]=tfdata(th(ku));
        num(:,ku)=num1;
        deno(:,ku)=deno1;

        dnum(:,ku)=dnum1;
        dden(:,ku)=dden1;

    end
end

