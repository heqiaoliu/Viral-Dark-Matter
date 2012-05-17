function gftable(m,prim_poly)
%GFTABLE Generate a MAT-file to accelerate Galois field computations.
%   GFTABLE(M,PRIM_POLY) generates two tables which will significantly speed up
%   computations over a Galois field. Use this function if you plan to do many
%   calculations with nondefault primitive polynomials. Tables already exist for
%   every default primitive polynomial. 
%
%   The tables are stored in the MAT-file userGftable.mat in the working
%   directory. Once this file is created it needs to be on the MATLAB path, or
%   in the working directory. See the ADDPATH command for instructions on adding
%   a directory to the MATLAB path.
%
%   Note: If PRIM_POLY is the default primitive polynomial for GF(2^M) listed in
%   the table on the GF reference page, then this function has no effect. A
%   MAT-file in your MATLAB installation already includes information that
%   facilitates computations with respect to the default primitive polynomial.
%
%   See also GF.

%    Copyright 1996-2009 The MathWorks, Inc.
%    $Revision: 1.5.4.8 $  $Date: 2009/03/30 23:24:14 $ 

global GF_TABLE_STRUCT GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2   %#ok - GF_TABLE_M and GF_TABLE_PRIM_POLY might be cleared

% check to see if the m and prim_poly already exist in 
% either userGftable or gftable
if((exist('userGftable.mat', 'file') == 2))
    clear GF_TABLE_M GF_TABLE_PRIM_POLY
    load userGftable.mat
    
    % Ensure that all elements are uint32, in case any old versions of
    % userGftable are in existence.
    for idx = 1 : length(GF_TABLE_STRUCT)
        GF_TABLE_STRUCT(idx).prim_poly = uint32(GF_TABLE_STRUCT(idx).prim_poly);
        GF_TABLE_STRUCT(idx).table1    = uint32(GF_TABLE_STRUCT(idx).table1);
        GF_TABLE_STRUCT(idx).table2    = uint32(GF_TABLE_STRUCT(idx).table2);
    end
    
    if ~isempty(find(GF_TABLE_STRUCT(m).prim_poly==prim_poly, 1))
        fprintf(1,'This m and prim_poly are already in the MAT-file.\n')
        return
    end   
else
    load gftable
    clear GF_TABLE_M GF_TABLE_PRIM_POLY
    if ~isempty(find(GF_TABLE_STRUCT(m).prim_poly==prim_poly, 1))
        fprintf(1,'This m and prim_poly are already in the MAT-file.\n')
        return
    end
end

  x = gf(0:2^m-1,m, prim_poly)';
  
  % Turn off the gftable warning about lookup tables not being defined for
  % nondefault primitive polynomials, since the purpose of this function is to
  % create a .mat file for such polynomials.
  warnState = warning('off','comm:gftablewarning');
  x1 = x(3).^(0:2^m-2);
  warning(warnState);
  
  % Create indices corresponding to the integer values of x1.  For example, if
  % m=3 and prim_poly=13, then ind = [1 2 4 5 7 3 6].
  ind = double(x1.x);
  
  % Create a vector corresponding to the exponential representation of the field
  % elements.  For example, if m=3 and prim_poly=13, then x = [0 1 5 2 3 6 4].
  [notUsed, x] = sort(ind);
  x = x - 1;

  table = [[ind'; 1] [-1; x']];
  if isempty(GF_TABLE_STRUCT(m).prim_poly)
      GF_TABLE_STRUCT(m).prim_poly = uint32(prim_poly);
      GF_TABLE_STRUCT(m).table1 = uint32(table(2:end,1));
      GF_TABLE_STRUCT(m).table2 = uint32(table(2:end,2));
  else
      GF_TABLE_STRUCT(m).prim_poly(end+1) = uint32(prim_poly);
      GF_TABLE_STRUCT(m).table1(:,end+1) = uint32(table(2:end,1));
      GF_TABLE_STRUCT(m).table2(:,end+1) = uint32(table(2:end,2));
  end

%assign tables to the global workspace
GF_TABLE1 = uint32(table(2:end,1));
GF_TABLE2 = uint32(table(2:end,2));


save userGftable GF_TABLE_STRUCT
fprintf(1,['Tables have been saved for m=%g and prim_poly=%g in userGftable.mat.\n'...
        'In order to use these tables, userGftable.mat must be on the MATLAB path\n'...
        'or in the working directory.\n'],m, prim_poly);  
