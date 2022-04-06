function [] = AlignROI(Im1,Im2,output)
%the function will write Im1 in the space of Im2 as a new image 
%'output'. Enjoy! 
% Matan Mazor 2019 github.com/matanmazor

    matlabbatch{1}.spm.util.imcalc.input = {Im1 % normalised image from your participant
                                            Im2 %ROI in MNI space
                                            };
    matlabbatch{1}.spm.util.imcalc.output = output;
    matlabbatch{1}.spm.util.imcalc.outdir = {''};
    matlabbatch{1}.spm.util.imcalc.expression = 'i2>0.5';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
    spm_jobman('run',matlabbatch);


end

