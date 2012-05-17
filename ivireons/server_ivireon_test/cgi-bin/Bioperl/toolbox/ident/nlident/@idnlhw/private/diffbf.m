function [DB, DF] = diffbf(ncind, nb,nf,nk)
% Compute DB and DF (for transfer function derivation)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 14:48:32 $

% Author(s): Qinghua Zhang

[ny, nu] = size(nb);

DB = cell(ny,1);
DF = cell(ny,1);
  
for ky=1:ny
  nblinpm = sum(nf(ky,:)+nb(ky,:)-double(ncind(ky,:)>0));  % Number of linear filter parameters for ky
  DB{ky} = cell(nblinpm,1);
  DF{ky} = cell(nblinpm,1);

  kd = 0;
  for ku=1:nu
    if ncind(ky,ku)~=0
      for kk=[(1:(ncind(ky,ku)-nk(ky,ku)-1)), ((ncind(ky,ku)-nk(ky,ku)+1):nb(ky,ku))]
        kd = kd+1;
        DB{ky}{kd} = [zeros(1,kk+nk(ky,ku)-1), 1];
        DF{ky}{kd} = 0;
      end
    else
      for kk=1:nb(ky,ku)
        kd = kd+1;
        DB{ky}{kd} = [zeros(1,kk+nk(ky,ku)-1), 1];
        DF{ky}{kd} = 0;
      end
    end
    for kk=1:nf(ky,ku)
      kd = kd+1;
      DB{ky}{kd} = 0;
      DF{ky}{kd} = [zeros(1,kk), 1];
    end
  end
end

% FILE END
