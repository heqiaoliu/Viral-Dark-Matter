function v = pctdemo_aux_proftaskpar(type)
%PCTDEMO_AUX_PROFTASKPAR Run computations, possibly in parallel
%   v = pctdemo_aux_proftaskpar(type) performs a fixed set of computations.
%   The manner in which the computations are performed depends on the value of
%   type.  Permissible values are 'serial', 'drange' and 'parfor', corresponding
%   to a serial for-loop, a for-drange loop and a parfor-loop, respectively.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/20 15:31:34 $

switch(lower(type))   
    case 'serial' % The original serial for-loop 
        v = zeros( 1, 300);
        for ii=1:300;
            v(ii) = max( abs( eig( rand( ii ) ) ) );
        end;
        
    case 'drange'
        v = zeros( 1, 300, codistributor() ); % Using for drange to speedup the for-loop

        disp('Start of for-drange loop.');
        disp('The computational complexity increases with the loop index.');
        for ii = drange(1:300)
            v(ii) = max( abs( eig( rand( ii ) ) ) );
        end
        disp( 'Done' );

    case 'parfor' % Using parfor to achieve better dynamic distribution of tasks
        v = zeros( 1, 300);
        disp('Start of parfor loop.');
        disp('The computational complexity increases with the loop index.');
        parfor ii = 1:300
            v(ii) = max( abs( eig( rand( ii ) ) ) );
        end
        disp( 'Done' );

end
