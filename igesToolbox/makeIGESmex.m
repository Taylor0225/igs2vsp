function makeIGESmex()
% Makefile
% run
% >> makeIGESmex
% in MATLAB to compile the C source code in the IGES-toolbox
% 
% A C-compiler must be installed.
% You can use the MathWorks Add-on MinGW compiler
%
% Remark! The compilation might take a couple of minutes

listing = dir('*.c');

for i=1:length(listing)
    try
        fprintf('\nCompiling %s ...\n\n',listing(i).name);
        mex(listing(i).name)
    catch
        fprintf('\n')
        warning('Could not compile 请配置编译器%s\n',listing(i).name);
    end
end
