function slsincos(newValue)
% 
% This is a private mask helper file for sine and cosine blocks in 
% Simulink table lookup library.
%
% Copyright 1995-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/12/16 21:58:45 $

% enum
Sine    = 1;
Cosine  = 2;
Expo    = 3;
SinCos  = 4;

blk = gcb;
hasSine   = exist_block(blk, 'sin(2*pi*u)');
hasCos    = exist_block(blk, 'cos(2*pi*u)');
if hasSine
    if hasCos
        oldValue = SinCos;
    else
        oldValue = Sine;
    end
else
    if hasCos
        oldValue = Cosine;
    else
        oldValue = Expo;
    end
end

if (newValue ~= oldValue)
    
    switch (oldValue)
        case (Sine)
            switch (newValue)
                case Cosine
                    sin2cos(blk);
                case Expo
                    sin2exp(blk);
                case SinCos
                    sin2sincos(blk);
            end
        
        case (Cosine)
            switch (newValue)
                case Sine
                    cos2sin(blk);
                case Expo
                    cos2sin(blk);
                    sin2exp(blk);
                case SinCos
                    cos2sin(blk);
                    sin2sincos(blk);
            end
        
        case (Expo)
            switch (newValue)
                case Sine
                    exp2sin(blk);
                case Cosine
                    exp2sin(blk);
                    sin2cos(blk);
                case SinCos
                    exp2sin(blk);
                    sin2sincos(blk);
            end
        
        case (SinCos)
            switch (newValue)
                case Sine
                    sincos2sin(blk);
                case Cosine
                    sincos2sin(blk);
                    sin2cos(blk);
                case Expo
                    sincos2sin(blk);
                    sin2exp(blk);
            end
        
    end
    
end
    
    

%%%%%%%%%%%%%%%%%%%%%%
%   HELPER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%
function sincos2sin(blk)
delete_line(blk, 'u/1', 'Cosine/1');
delete_line(blk, 'Cosine/1', 'cos(2*pi*u)/1');
delete_block([blk, '/Cosine']);
delete_block([blk, '/cos(2*pi*u)']);

function exp2sin(blk)
set_param([blk '/exp(j*2*pi*u)'], 'name', 'sin(2*pi*u)');
delete_line(blk, 'u/1', 'Cosine/1');
delete_line(blk, 'Sine/1', 'ToCplx/2');
delete_line(blk, 'Cosine/1', 'ToCplx/1');
delete_line(blk, 'ToCplx/1', 'sin(2*pi*u)/1');
delete_block([blk, '/Cosine']);
delete_block([blk, '/ToCplx']);
add_line(blk, 'Sine/1', 'sin(2*pi*u)/1');

function cos2sin(blk)
pos = get_param([blk '/Cosine'], 'position');
delete_line(blk, 'u/1', 'Cosine/1');
delete_line(blk, 'Cosine/1', 'cos(2*pi*u)/1');
delete_block([blk, '/Cosine']);
set_param([blk '/cos(2*pi*u)'], 'name', 'sin(2*pi*u)');
add_block('sl_helperblocks/Sine', [blk, '/Sine'], 'position', pos);
add_line(blk, 'u/1', 'Sine/1');
add_line(blk, 'Sine/1', 'sin(2*pi*u)/1');

function sin2cos(blk)
pos = get_param([blk '/Sine'], 'position');
delete_line(blk, 'u/1', 'Sine/1');
delete_line(blk, 'Sine/1', 'sin(2*pi*u)/1');
delete_block([blk, '/Sine']);
set_param([blk '/sin(2*pi*u)'], 'name', 'cos(2*pi*u)');
add_block('sl_helperblocks/Cosine', [blk, '/Cosine'], 'position', pos);
add_line(blk, 'u/1', 'Cosine/1');
add_line(blk, 'Cosine/1', 'cos(2*pi*u)/1');

function sin2exp(blk)
posCos    = [105    24   160    66];
posToCplx = [200    53   230    82];
delete_line(blk, 'Sine/1', 'sin(2*pi*u)/1');
set_param([blk '/sin(2*pi*u)'], 'name', 'exp(j*2*pi*u)');
add_block('built-in/RealImagtoComplex', [blk '/' 'ToCplx'], ...
    'position', posToCplx, 'Input', 'Real and imag');
add_block('sl_helperblocks/Cosine', [blk, '/Cosine'], 'position', posCos);
add_line(blk, 'u/1', 'Cosine/1');
add_line(blk, 'Sine/1',   'ToCplx/2');
add_line(blk, 'Cosine/1', 'ToCplx/1');
add_line(blk, 'ToCplx/1', 'exp(j*2*pi*u)/1');

function sin2sincos(blk)
posCos = [105   144   160   186];
posOut = [265   158   295   172];
add_block('sl_helperblocks/Cosine', [blk, '/Cosine'], 'position', posCos);
add_block('built-in/Outport', [blk, '/cos(2*pi*u)'], 'position', posOut);
add_line(blk, 'u/1', 'Cosine/1');
add_line(blk, 'Cosine/1', 'cos(2*pi*u)/1');

function present = exist_block(sys, name)
present = ~isempty(find_system(sys,'searchdepth',1,...
    'followlinks','on','lookundermasks','on','name',name));
    
% [EOF]
