function [nyr,nu,nf,spe] = size(sys,nr)
%SIZE  size for idfrd objects
% [NY,NU,NF,NYS] = SIZE(H)
%     Returns the number the number of output channels (NY),
%     the number of input channels (NU), the number of frequencies (NF),
%     and the number of SpectrumData Channels (NYS).
%
%     SIZE(H) by itself displays the information.
%
%     NY = SIZE(H,1) or NY = SIZE(H,'NY');
%     NU = SIZE(H,2) or NU = SIZE(H,'NU');
%     NF = SIZE(H,3) or NF = SIZE(H,'NF');
%     NYS = SIZE(H,4) or NYS = SIZE(H,'NYS');
%
%     Nn = SIZE(H) returns Nn = [NY,NU,NF,NYS] .

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2006/09/30 00:19:07 $

resp=sys.ResponseData;
[ny1,nu1,nf1]=size(resp);
[ny2,nu2,nf2]=size(sys.SpectrumData); %nf is 1 if sys.Spec = []
ny = max(ny1,ny2);
nu = nu1;
nf = max(nf1*~isempty(resp),nf2*~isempty(sys.SpectrumData)); %changed to check for empty matrices (r.s.)
spe = ny2;
if nargin==2
   switch lower(nr)
   case {1,'ny'}
      ny = ny;
   case {2,'nu'}
      ny = nu;
   case {3,'nf'}
      ny = nf;
   case {4,'spe'}
      ny = spe;
   end
elseif nargout==1
   ny =[ny nu nf spe];
elseif nargout == 0
   disp(sprintf(['Frequency domain data with %d outputs and %d inputs,',...
         '\n%d frequency values and %d spectrum channels.'],ny,nu,nf,spe)) 
end
if ~(nargin==1&nargout==0)
   nyr =ny;
end

