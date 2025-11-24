function processScratch(input_image_path, crop_ouput_folder, window_output_folder, windowHeight){
	open(input_image_path);
	wellID = getTitle();
	selectWindow(wellID);
	Image.removeScale;
	setBackgroundColor(0, 0, 0);
	makeOval(0, 0, 10598, 10598);
	run("Clear Outside");
	setMinAndMax(40000, 65535);
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=50000-Infinity pixel add");
	
	M = roiManager("count");
	if (M == 0){
		selectWindow(wellID);
		run("Close");
		selectWindow("ROI Manager");
		run("Close");
		return;
	}
	
	k_max = 0;
	A_max = 0;
	for (k = 0; k<M; k++){
		roiManager("select", k);
		run("Measure");
		area_ROI = getResult("Area", nResults-1);
		if (area_ROI > A_max) {
			k_max = k;
			A_max = area_ROI;
		}
		selectWindow("Results");
		IJ.deleteRows(nResults-1, nResults-1);
	}
	setBackgroundColor(0, 0, 0);
	selectWindow(wellID);
	roiManager("Select", k_max);
	run("Clear Outside");
	selectWindow(wellID);
	setForegroundColor(255, 255, 255);
	roiManager("Select", k_max);
	run("Fill");
	
	roiManager("Deselect");
	roiManager("Delete");
	run("Analyze Particles...", "size=0-Infinity pixel add");
	roiManager("Select", 0);
	run("Measure");
	roiManager("Select", 0);
	run("Duplicate...", "title=crop");
	selectWindow(wellID);
	run("Close");
	selectWindow("crop");
	saveAs("tiff", crop_ouput_folder + wellID);
	roiManager("Deselect");
	roiManager("Delete");
	selectWindow(wellID);
	rename("crop");
	selectWindow("crop");
	getDimensions(crop_width, crop_height, channels, slices, frames);
	makeRectangle(0, (crop_height - windowHeight)/2, crop_width, windowHeight);
	roiManager("Add");
	roiManager("Select", 0);
	run("Duplicate...", "title=window");
	selectWindow("crop");
	run("Close");
	roiManager("Deselect");
	roiManager("Delete");
	selectWindow("window");
	run("Analyze Particles...", "size=0-Infinity pixel add");
	N = roiManager("count");
	j_max = 0;
	area_max = 0;
	for (j = 0; j<N; j++){
		roiManager("select", j);
		run("Measure");
		ROI_area = getResult("Area", nResults-1);
		if (ROI_area > area_max) {
			j_max = j;
			area_max = ROI_area;
		}
		selectWindow("Results");
		IJ.deleteRows(nResults-1, nResults-1);
	}
	selectWindow("window");
	roiManager("Select", j_max);
	run("Clear Outside");
	roiManager("Deselect");
	roiManager("Delete");
	selectWindow("ROI Manager");
	run("Close");
	selectWindow("window");
	saveAs("tiff", window_output_folder + wellID);
	run("Close");
}

setOption("JFileChooser", true);
plate_directory = getDirectory("Choose Plate:");
wells = getFileList(plate_directory);
well_num = wells.length;
plate_number = split(wells[0], "_");
measurements_directory = getDirectory("Choose Measurements Ouput Folder:");
skeleton_input_directory = getDirectory("Choose Skeleton Analysis Input Folder:");
MATLAB_width_input_directory = getDirectory("Choose MATLAB Input Folder:");
// Window Height: 2 mm (1.625 um/px)
windowHeight = 1231;
setBatchMode("show");

run("Set Measurements...", "area perimeter feret's display redirect=None decimal=9");
for (i = 0; i<well_num; i++){
	well_directory = plate_directory + wells[i];
	processScratch(well_directory, skeleton_input_directory, MATLAB_width_input_directory, windowHeight);
}

selectWindow("Results");
saveAs("results", measurements_directory + plate_number[0] + ".csv");
run("Close");
