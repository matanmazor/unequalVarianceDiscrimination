function [  ] = FIL2BIDS (source_dir, target_dir, sequence_names, sequence_idxs)
%FIL2BIDS Gets as input a list of directories and rearranges them in BIDS
%format.
%input: 
%-source_dir: the main subject directory, as retrieved from Charm
%-target_dir: the subject directory, usually named sub-[subject_identifier]
%-sequence_names: a cell array with the sequence types to convert. for
%example, {'anat','func','fmap'};
%=sequence_idxs: a cell array with the corresponding sequence indices. For
%example, {2, 6:10, 3:4};


%Matan Mazor, 2018

%dependencies:
addpath('D:\Documents\software\xiangruili-dicm2nii-ae1d301');

for i_seq=1:length(sequence_names)
    
    sequence_name = sequence_names{i_seq};
    sequence_idx = sequence_idxs{i_seq};
    
    %% 0. Sanity checks
    if sum(strcmp(sequence_name, {'func','fmap','anat'}))==0
        error('Unknown sequence name')
    end

    %% 1. Create subdirectories
    if ~exist(fullfile(target_dir, sequence_name))
        mkdir(fullfile(target_dir, sequence_name))
    elseif strcmp(sequence_name,'fmap')
        delete(fullfile(target_dir, 'fmap'))
        mkdir(fullfile(target_dir, sequence_name))
    end

    %% 2. Untar directories
    mkdir(fullfile(source_dir, sequence_name));
    subj_id = source_dir(end-10:end-4);
    for i_idx=1:length(sequence_idx(:))
        untar(fullfile(source_dir, strcat(subj_id,'_FIL.S',num2str(sequence_idx(i_idx)),'.tar')),...
            fullfile(source_dir, sequence_name));
    end

    %% 3. Save as niftis and jsons
    dicm2nii(fullfile(source_dir, sequence_name),fullfile(target_dir, sequence_name),'nii')
    rmdir(fullfile(source_dir, sequence_name),'s');

    %% 4. Validate that everything makes sense, and then change file names
    switch sequence_name
        case 'anat'
            %here I assume that the anatomical image should be mprage
            if ~exist(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.json'), 'file')
                error('Couldn''t find MPRAGE_64ch_Head.json')
            elseif ~exist(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.nii'), 'file')
                error('Couldn''t find MPRAGE_64ch_Head.nii.gz')
            end
            
            %deface 
            spm_deface({fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.nii')});

            movefile(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.json'),...
                fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_T1w.json')));
            
            movefile(fullfile(target_dir, sequence_name, 'anon_MPRAGE_64ch_Head.nii'),...
                fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_T1w.nii')));
            
            delete(fullfile(target_dir, sequence_name,'dcmHeaders.mat'));
            delete(fullfile(target_dir, sequence_name,'MPRAGE_64ch_Head.nii'));


        case 'fmap'
            
            %here I assume that the _events.tsv files have already been placed in the
            %folder and that they are ordered like the functional scannings
            tsv_files = dir(fullfile(target_dir,'func','*_events.tsv'));
            
            
            %the many and single for mag correspond to a case where there
            %are many fieldmaps per subejct, versus single fieldmap per
            %subject. 
            mag_single_jsons = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.json'));
            mag_many_jsons = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_s*.json'));
            phase_jsons = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase*.json'));
            mag_single_niis = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.nii'));
            mag_many_niis = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_s*.nii'));
            phase_niis = dir(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase*.nii'));
            
            if isempty(mag_many_jsons) & isempty(mag_single_jsons)
                error('Couldn''t find gre_field_mapping_1acq_rl.json')
            elseif isempty(phase_jsons)
                error('Couldn''t find gre_field_mapping_1acq_rl_phase.json')
            elseif isempty(mag_many_niis) & isempty(mag_single_niis)
                error('Couldn''t find gre_field_mapping_1acq_rl.json')
            elseif isempty(phase_niis)
                error('Couldn''t find gre_field_mapping_1acq_rl_phase.nii')
            end
            
            if ~isempty(mag_many_jsons) %many files case
                
                for i_nii=1:length(mag_many_niis)
                    spm_file_split(fullfile(target_dir, sequence_name, mag_many_niis(i_nii).name));
                end
                
                all_files = dir(fullfile(target_dir, sequence_name));
                
                for i_run=1:length(tsv_files)
                    
                    run_name = tsv_files(i_run).name(1:regexp(tsv_files(i_run).name,'_events.tsv')-1);
                    
                    mag_suffix = sprintf('s%03d',sequence_idx(i_run,1));
                    phase_suffix = sprintf('s%03d',sequence_idx(i_run,2));

                    % change json file name
                    copyfile(fullfile(target_dir, sequence_name, strcat('gre_field_mapping_1acq_rl_',mag_suffix,'.json')),...
                    fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.json')));

                    copyfile(fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.json')),...
                    fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude2.json')));

                    copyfile(fullfile(target_dir, sequence_name, strcat('gre_field_mapping_1acq_rl_',mag_suffix,'_00001.nii')),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.nii')));

                    copyfile(fullfile(target_dir, sequence_name, strcat('gre_field_mapping_1acq_rl_',mag_suffix,'_00002.nii')),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude2.nii')));

                    copyfile(fullfile(target_dir, sequence_name, strcat('gre_field_mapping_1acq_rl_phase_',phase_suffix,'.json')),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_phasediff.json')));

                    copyfile(fullfile(target_dir, sequence_name, strcat('gre_field_mapping_1acq_rl_phase_',phase_suffix,'.nii')),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_phasediff.nii')));
            
                end
                
               for i_f=1:length(all_files)
                    if isfile(fullfile(target_dir,sequence_name,all_files(i_f).name))
                    delete(fullfile(target_dir,sequence_name,all_files(i_f).name))
                    end
                end

                
            else %single file case
                
                spm_file_split(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.nii'));
                all_files = dir(fullfile(target_dir, sequence_name));

                
                for i_run=1:length(tsv_files)
                    
                    run_name = tsv_files(i_run).name(1:regexp(tsv_files(i_run).name,'_events.tsv')-1);
                    % change json file name

                    copyfile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.json'),...
                    fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.json')));

                    copyfile(fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.json')),...
                    fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude2.json')));

                    copyfile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_00001.nii'),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude1.nii')));

                    copyfile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_00002.nii'),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_magnitude2.nii')));

                    copyfile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.json'),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_phasediff.json')));

                    copyfile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.nii'),...
                        fullfile(target_dir, sequence_name, strcat(run_name,'_phasediff.nii')));
            
                end
                
                for i_f=1:length(all_files)
                    if isfile(fullfile(target_dir,sequence_name,all_files(i_f).name))
                    delete(fullfile(target_dir,sequence_name,all_files(i_f).name))
                    end
                end
            end
            

        case 'func'
            %here I assume that the _events.tsv files have already been placed in the
            %folder and that they are ordered like the functional scannings
            tsv_files = dir(fullfile(target_dir,'func','*_events.tsv'));
            json_files = dir(fullfile(target_dir,'func','*.json'));
            image_files = dir(fullfile(target_dir,'func','*.nii'));
            if size(tsv_files) ~= size(json_files) 
                error('different number of event files and functional scans')
            end
            
            %% FIX CENTER's TR and TE
            for i_json=1:length(json_files)
                    jsonText = fileread(fullfile(target_dir, sequence_name, json_files(i_json).name));
                    % Convert JSON formatted text to MATLAB data types (3x1 cell array in this example)
                    jsonData = jsondecode(jsonText); 
                    % Change HighPrice value in Row 3 from 10000 to 12000
                    jsonData.RepetitionTime=3.36;
                    jsonData.EchoTime=0.03;
                    % Convert to JSON text
                    jsonText2 = jsonencode(jsonData);
                    % Write to a json file
                    fid = fopen(fullfile(target_dir, sequence_name, json_files(i_json).name), 'w');
                    fprintf(fid, '%s', jsonText2);
                    fclose(fid);
            end
            
            for i_tsv=1:length(tsv_files)
                run_name = tsv_files(i_tsv).name(1:regexp(tsv_files(i_tsv).name,'_events.tsv')-1);
                % change json file name
                movefile(fullfile(target_dir, sequence_name, json_files(i_tsv).name),...
                           fullfile(target_dir, sequence_name, strcat(run_name,'_bold.json'))); 
                movefile(fullfile(target_dir, sequence_name, image_files(i_tsv).name),...
                           fullfile(target_dir, sequence_name, strcat(run_name,'_bold.nii'))); 
            end
            
          delete(fullfile(target_dir, sequence_name,'dcmHeaders.mat'));


    end

end

