function sys = loadobj(s)
%LOADOBJ  Load filter for SS objects

%   Author(s): G. Wolodkin, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.7 $  $Date: 2010/02/08 22:28:36 $
if isa(s,'ss')
   sys = s;
else
   % Issue warning
   updatewarn
   
   if isfield(s,'Version_')
      % Versions 10- (MCOS)
      
   elseif isfield(s,'a')
      % Versions 1-4
      switch s.lti.Version
         case 1
            % Version 1: double storage of a,b,..., no array support
            sys = dss(s.a,s.b,s.c,s.d,s.e,'StateName',s.StateName);
         case 2
            % Version 2: double storage of a,b,... with array support.
            % Field Nx stores state dimension
            if isscalar(s.Nx)
               sys = dss(s.a,s.b,s.c,s.d,s.e,'StateName',s.StateName);
            else
               sys = ss(s.d);
               Data = sys.Data_;
               ne = size(s.e,1);
               for ct=1:numel(s.Nx)
                  nx = s.Nx(ct);
                  Data(ct).a = s.a(1:nx,1:nx,ct);
                  Data(ct).b = s.b(1:nx,:,ct);
                  Data(ct).c = s.c(:,1:nx,ct);
                  if ne>0
                     Data(ct).e = s.e(1:nx,1:nx,ct);
                  end
                  if length(s.StateName)==nx && ~all(strcmp(s.StateName,''))
                     Data(ct).StateName = s.StateName;
                  else
                     Data(ct).StateName = [];
                  end
               end
               sys.Data_ = Data;
            end
         case {3,4}
            % Versions 3 and 4: cell-based representation of ss arrays
            if isscalar(s.a)
               sys = dss(s.a{1},s.b{1},s.c{1},s.d,s.e{1},'StateName',s.StateName);
            else
               sys = ss(s.d);
               Data = sys.Data_;
               for ct=1:numel(s.a)
                  a = s.a{ct};
                  nx = size(a,1);
                  Data(ct).a = a;
                  Data(ct).b = s.b{ct};
                  Data(ct).c = s.c{ct};
                  Data(ct).e = s.e{ct};
                  if length(s.StateName)==nx && ~all(strcmp(s.StateName,''))
                     Data(ct).StateName = s.StateName;
                  else
                     Data(ct).StateName = [];
                  end
               end
               sys.Data_ = Data;
            end
      end
      
      % Set LTI properties last because of I/O delays (once converted
      % to I/O delays, B,C,D can't be manipulated directly)
      sys = reload(sys,s.lti);

   else
      % Versions 5-9 (LTI2 - two-layer architecture)
      sys = ss;
      sys = reload(sys,s.lti);
   end
end
