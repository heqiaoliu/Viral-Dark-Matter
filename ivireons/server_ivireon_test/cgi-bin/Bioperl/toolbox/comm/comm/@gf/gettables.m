function [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x)
%
% Copyright 1996-2006 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2006/10/10 02:10:03 $

if((exist('userGftable.mat', 'file') == 2))
    load userGftable
    
    % Ensure that all elements are uint32, in case any old versions of
    % userGftable are in existence.
    for idx = 1 : length(GF_TABLE_STRUCT)  %#ok - from .mat file
        GF_TABLE_STRUCT(idx).prim_poly = uint32(GF_TABLE_STRUCT(idx).prim_poly); %#ok - from .mat file
        GF_TABLE_STRUCT(idx).table1    = uint32(GF_TABLE_STRUCT(idx).table1);    %#ok - from .mat file
        GF_TABLE_STRUCT(idx).table2    = uint32(GF_TABLE_STRUCT(idx).table2);    %#ok - from .mat file
    end
    
else
    load gftable
end

   if isempty(GF_TABLE_STRUCT(x.m).prim_poly)
     ind = [];
   else
     ind = find(GF_TABLE_STRUCT(x.m).prim_poly==x.prim_poly);
   end

   if isempty(ind)
     if x.m>2
       str = sprintf(['Lookup tables not defined for this order 2^%g and\n' ...
                   'primitive polynomial %g.  Arithmetic still works\n' ...
                   'correctly but multiplication, exponentiation, and\n' ...
                   'inversion of elements is faster with lookup tables.\n' ...
                   'Use gftable to create and save the lookup tables.'],...
                     x.m,double(x.prim_poly));
       warning('comm:gftablewarning',str)  %#ok - str has line returns
     end
     GF_TABLE1 = [];
     GF_TABLE2 = [];
   else
     GF_TABLE1 = GF_TABLE_STRUCT(x.m).table1(:,ind);
     GF_TABLE2 = GF_TABLE_STRUCT(x.m).table2(:,ind);
   end
   GF_TABLE_M = x.m;
   GF_TABLE_PRIM_POLY = x.prim_poly;
   

