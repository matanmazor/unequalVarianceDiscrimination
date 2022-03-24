# Unequal Variance Discrimination vs Detection

Experiment comparing detection and discrimination with unequal variance, following up on an imaging experiment.
Run at the Wellcome Centre for Human Neuroimaging, UCL

To run the experiment:

1. Load 'experiment\data\subjects.mat'. This is a dictionary with paricipant identifiers as keys and numeral values. A value of 1 means higher confidence is mapped to bigger circles. A value of 2 means lower confidence is mapped to bigger circles.
2. Add a participant identifier that starts with a 3-digit number. For example, to add the participant '001KaFr', and to map high confidence to big circles, type in `subjects('001KaFr')=1`. 
3. Save the ammended subject list (`save('experiment\data\subjects.mat','subjects')`).
4. Run the _openEndedCalibration.m_ function from within the experiment directory. In the user input box, type in the participant identifier you added to the subjects list. This function will calibrate transparency for each of the three tasks to reach around 70% accuracy.
5. Now _main.m_ can be run. To practice discrimination, detection, or tilt recognition, type '10','11', or '12' in the _practice_ field. Otherwise, type '0'.
