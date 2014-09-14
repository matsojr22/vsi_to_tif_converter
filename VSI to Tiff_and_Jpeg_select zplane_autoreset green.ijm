//The following macro code was written by Matthew Jacobs in the Salk Institute's Callaway Neuroscience Lab. 
//It is designed to help convert Olympus Slide Scanner .vsi files into .tif files which can be opened in third party software. 
//This code does not keep 100% of the detail stored in the .vsi, but does give access to the detail scan information in the tif format. 
//There are continuing issues with the autoscaling of the fluorescent chanels, but each channel of the image can be manually scaled after conversion as desired.

//Disclaimer Dialog
Dialog.create("Disclaimer");
Dialog.addMessage("This macro is not smart. It is designed to be used on a 3 channel fluorescent .vsi file and can only convert a single focal plane at a time. The fluorescent channels MUST be in order: Blue, Green, and Red.");
Dialog.show();

//This Creates the dialogue for file extension selection. Really this is only here in case Olympus changes the file extension someday (imagine an updated format called .vsix)
Dialog.create("File type");
Dialog.addString("File suffix: (currently only works with .vsi)", ".vsi", 5);
Dialog.show();
suffix = Dialog.getString();

//This creates the dialogue for focal plane selection.
Dialog.create("Please select which focal plane (Z) you wish to use, you can look at the focal planes in OlyVia first...");
Dialog.addNumber("Zplane#", 1);
Dialog.show();
zplane = Dialog.getNumber();


inDir = getDirectory("Choose Directory Containing " + suffix + " Files ");
outDir = inDir;
setBatchMode(true);
processFiles(inDir, outDir, "");
print("Done!");

function processFiles(inBase, outBase, sub) {
  flattenFolders = true; // this flag controls output directory structure
  print("Processing folder: " + sub);
  list = getFileList(inBase + sub);
  if (!flattenFolders) File.makeDirectory(outBase + sub);
  for (i=0; i<list.length; i++) {
    path = sub + list[i];
    //upath = toUpperCase(path); Leave this line commented out, you only need it if the file extension is case sensitive. Again, this is future proofing against olympus altering the file extension.
    upath = path; //This code was easier to write, and might be replaced by the the previous line (some day) which someone suggested to me.
    if (File.isDirectory(inBase + path)) {
      processFiles(inBase, outBase, path);
      
    }
    else if (endsWith(upath, suffix)) {

    	print("Importing " + suffix + " = " + list[i] + ", Z-Plane#" + zplane);

		//The top line here does not use the zplane variable to select a focal plane to import. The second line uses the zplane string to selectively import that plane.
		//If you are using a virtual z image, you must select the focal plane you want to import. The top line here will simply use plane #1, which is rarely an in focus image.
		//obsolete command//run("Bio-Formats Importer", "open=["+inBase + path+"] autoscale color_mode=Custom split_channels view=Hyperstack stack_order=XYCZT series_1 series_0_channel_0_red=0 series_0_channel_0_green=0 series_0_channel_0_blue=255 series_0_channel_1_red=0 series_0_channel_1_green=255 series_0_channel_1_blue=0 series_0_channel_2_red=255 series_0_channel_2_green=0 series_0_channel_2_blue=0");
		run("Bio-Formats Importer", "open=["+inBase + path+"] autoscale color_mode=Custom specify_range split_channels view=Hyperstack stack_order=XYCZT series_1 c_begin_1=1 c_end_1=3 c_step_1=1 z_begin_1=zplane z_end_1=zplane z_step_1=0 series_0_channel_0_red=0 series_0_channel_0_green=0 series_0_channel_0_blue=255 series_0_channel_1_red=0 series_0_channel_1_green=255 series_0_channel_1_blue=0 series_0_channel_2_red=255 series_0_channel_2_green=0 series_0_channel_2_blue=0");

		//The following commands set the image titles to a simple string which the merge channel tool will accept.
		//The Green channel has special brightness&contrast alterations made here as well. These help it to better detect the weak GFP signal.
		print("Blue...");
		selectImage(1);
		title1 = getTitle();
		
		print("Green...");
		selectImage(2);
		title2 = getTitle();
		run("Enhance Contrast", "saturated=0.35");
		resetMinAndMax();
		
		print("Red...");
		selectImage(3);
		title3 = getTitle();

		//Merges channels and flattens image to a single layer
		print("Merging Channels...");
		run("Merge Channels...", "red=&title3 green=&title2 blue=&title1 gray=*None* cyan=*None* magenta=*None* yellow=*None*");

		//Rotates Image to upright position. All my scan images have the dorsal edge facing the bottom of the screen.
		print("Rotating brain...");
		run("Rotate... ", "angle=180 grid=1 interpolation=None");

		//Saves files in various formats.
		print("Saving .tiff");
		saveAs("Tiff", outBase + path);

		print("Saving .jpeg");
		saveAs("Jpeg", outBase + path);

		//Prep fiji for the next image by closing open windows and clearing out the cache.
		print("Closing open files...");
		run("Close All");
		
		print("Collecting Garbage...");
		run("Collect Garbage");
    }
  }
}
