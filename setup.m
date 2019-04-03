function setup(str1,str2)
rootDir = pwd;
addpath(pwd)
srcPath = genpath([rootDir '/src']); % all src live here for this project
libsPath = genpath([rootDir '/libs']); % all libs/dependencies live here for this project
if nargin > 0
    
    switch str1
        case 'install'
            addpath(srcPath, '-begin');
            addpath(libsPath, '-begin');
            disp('Successfully added libs to path.')
            statusStr = [str1 'ed'];

        case 'remove'
            warning('off')
            rmpath(libsPath);
            disp('Successfully removed libs from path.')
            warning('on')
            statusStr = [str1 'd'];

        otherwise
            disp('Unrecognized arg 1. Try >> setup add OR >> setup remove.')
            disp('Setup incomplete.')
            return
    end
    
    if nargin > 1
        
        switch str2
            
            case 'save'
                warning('You are about to make permanent changes to search path.')
                prompt = 'Would you like to continue? (y/n): ';
                str = input(prompt,'s');
                
                if strcmp(str, 'y')
                    savepath
                    disp(['Permanently ' statusStr ' project libs on search path.'])
                    
                elseif strcmp(str, 'n')
                    disp('Canceling permanent save.')
                    
                else
                    disp('Unrecognized input. Exiting without saving path')
                    return
                    
                end

            otherwise
                disp('Unrecognized arg 2. Try >> setup add save OR >> setup remove save.')
                return
                
        end
    end
else
    
end
