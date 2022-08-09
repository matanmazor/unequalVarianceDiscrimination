% Determine parameters for analysis. Change to your local settings.

project_params=struct();

% SPM directory (where is SPM installed?)
project_params.spm_dir = fullfile('D:','Documents','software','spm12');

% Location of raw data as it comes from the scanner
project_params.raw_dir = fullfile(fileparts(pwd),'data','raw_data'); 

% Location of preprocessed data
project_params.pp_dir = fullfile(fileparts(pwd),'data','pp_data'); 

% name of subdirectories
project_params.dir_epi = 'func';
project_params.dir_struct = 'anat';
project_params.dir_fm = 'fmap';
project_params.sess_prefix = 'run-';

% Location of analysis output
project_params.pp_dir = fullfile(fileparts(pwd),'analyzed'); 

% for computers at the Wellcome Centre for Human Neuroimaging
project_params.hostname = 'palladium';

% number of dummy scans before task
project_params.n_dum = 5;

project_params.TR = 3.3600; % (in seconds)

project_params.nslices = 48; % number of slices

% cutoff for highpass filter
project_params.hpcutoff = 128;

project_params.timeNorm = 1000;

project_params.slicetiming = 1;
project_params.realign = 1;
project_params.coregister = 1;
project_params.segment = 1;
project_params.normalise = 1;
project_params.smoothing = 1;
project_params.subgroup_maps = 1;

project_params.FWHM = 6; % smoothing kernel, in mm

project_params.resolEPI = [3 3 3]; %voxel size, in mm
project_params.sliceorder =  1:48; %ascending slice order;

project_params.scanner_signal = 'once per volume';

save('project_params.mat','project_params')

