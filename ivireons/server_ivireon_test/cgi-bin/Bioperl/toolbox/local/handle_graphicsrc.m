% Execute startup MATLAB file, if it exists.
startup_exists = exist('startuphandle_graphics','file');
if startup_exists == 2 || startup_exists == 6
    clear startup_exists
    startuphandle_graphics
else
    clear startup_exists
end

