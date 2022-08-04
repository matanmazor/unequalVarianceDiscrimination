These are voxel-wise beta values from the design matrix used for RSA 
analyses. 

E.g., the file 
sub-MP02935/rTPJ_bold

includes a containers.Map object (BOLD) with keys for the 12
combinations of responses (A(nticlockwise),C(lockwise),Y(yes),N(o),
V(ertical) and T(ilted)), and confidence levels (H(igh) and L(ow)).

BOLD('Y_L') is a n_voxels*n_runs matrix, with the voxel data for
this condition in every included run. The number of voxels per ROI
may be different for different subjects, because ROI masks are 
converted to the native space. 
