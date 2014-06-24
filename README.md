vsi_to_tif_converter
====================

The following macro code was written by Matthew Jacobs in the Salk Institute's Callaway Neuroscience Lab. It is designed to help batch convert Olympus Slide Scanner .vsi files into .tif files which can be opened in third party software. This code does not keep 100% of the detail stored in the .vsi, but does give access to the detail scan information in the tif format. There are continuing issues with the autoscaling of the fluorescent chanels, but each channel of the image can be manually scaled after conversion as desired. This code is designed to run in the Fiji distribution of imageJ, on a 3 channel image using dapi, fitc, and tritc. It can easily be modified to work on any .vsi file you would like to convert. If given a directory, this macro will recursively scan and process each .vsi file. Care must betaken to remove any "Overview" vsi files which are not 3-channel images, else the code will crash at this point.

Updates will be made as I slowly decide which features are important enough to our lab, and our future research.
