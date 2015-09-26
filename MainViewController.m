//
//  MainViewController.m
//  RangeFinder
//
//  Created by Chris Lamb on 6/3/12.
//  Copyright (c) 2012 CPL Consulting. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@implementation MainViewController {
    CGFloat firstZoomFactor;
    float secondZoomFactor;
    float totalZoomFactor;
    float flagHeight;
    UIImageView *reticleView;
    UIImagePickerController *imagePickerController;

    NSString *distanceUnits;
    NSString *objectName;
    NSString *height;
    NSString *heightUnits;
}
// @synthesize helpView = _helpView;

#define FUTZ_FACTOR 6.0

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
// Checks to see if the camera is available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"camera is available - We must be on the iPhone!");
        self.myAssistantLabel.text = @"App Assistant";
    }
    else {
        NSLog(@"camera is NOT available - We must be on the Simulator!");
        self.myAssistantLabel.text = @"The camera is not available on this device";
        self.cameraButtonButton.hidden = YES;
    }
   // CGRect frame = CGRectMake(130.0, 150.0, 60.0, 120.0);
   // reticleView = [[UIImageView alloc] initWithFrame:frame];
   // reticleView.image = [UIImage imageNamed:@"dwg06.png"];
   // reticleView.userInteractionEnabled = YES;
// Builds a view to overlay over the camera view including the zoom factor
    CGRect frame = CGRectMake(80.0, 150.0, 160.0, 120.0);
    //CGRect frame = CGRectMake(130.0, 150.0, 60.0, 120.0);
    //self.reticleView = [[UIImageView alloc] initWithFrame:frame];
    //self.reticleView.image = [UIImage imageNamed:@"dwg06.png"];
    reticleView = [[UIImageView alloc] initWithFrame:frame];
    reticleView.image = [UIImage imageNamed:@"Reticle(2).png"];
    reticleView.userInteractionEnabled = YES;

    self.helpView.hidden = YES;
    
// Sets up labels & initial values
    heightUnits = @"foot";
    height = @"6";
    objectName = @"Golf Flag";
    distanceUnits = @"yard";

    self.distanceObjectLabel.text = [NSString stringWithFormat:@"Distant object is a %@ %@ high %@", height, heightUnits, objectName];
    self.myAssistantLabel.text = @"Tap to open RangeFinder";
    
// Builds the slider and rotates it 90 degrees
    CGRect sliderFrame = CGRectMake(-20.0, 50.0, 150.0, 50.0);
    self.reticleZoomSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
    self.reticleZoomSlider.transform = trans;
    [reticleView addSubview:self.reticleZoomSlider];
    
 //   UIViewController *upperVC = self.presentingViewController;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Custom Methods

- (IBAction)testButton:(id)sender
{
    NSLog(@"testButton is for testing singleton action");
    self.theDistantObject = [DistantObject getSingeltonInstance];
    
    heightUnits = self.theDistantObject.heightUnits;
    height = self.theDistantObject.height;
    objectName = self.theDistantObject.objectName;
    distanceUnits = self.theDistantObject.distanceUnits;
    
    flagHeight = [height floatValue];
    
    self.distanceObjectLabel.text = [NSString stringWithFormat:@"Distant object is a %@ %@ high %@", height, heightUnits, objectName];
}

- (IBAction)showHelpButton:(id)sender
{
    NSLog(@"slides up a transparency that describes the buttons below");
    if (self.helpView.hidden) {
        self.helpView.hidden = NO;
    }
}

- (IBAction)hideHelpButton:(id)sender
{
    NSLog(@"hides the transparency that describes the buttons below");
    if (!self.helpView.hidden) {
        self.helpView.hidden = YES;
    }
}


- (IBAction)camera:(UIButton *)sender {
    NSLog(@"trying to get the camera controls to show!");
    
// Sets self to be the ImagePickerController delegate
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
// Configures the camera & presents the modal camera view
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing = YES;
    imagePickerController.showsCameraControls = YES;
    imagePickerController.cameraOverlayView = reticleView;
    [self presentModalViewController:imagePickerController animated:YES];

}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
// Displays the INITIAL zoom factor by getting cropped rectangle dimensions
    NSValue *imageRectangle = [info objectForKey:UIImagePickerControllerCropRect];
    CGRect rectangleValue = [imageRectangle CGRectValue];
    CGFloat zoomFactor = (1937.0 / rectangleValue.size.height);
    NSLog(@"CropRect ZoomFactor is in %2.3f", zoomFactor);
    
// Displays the FINAL zoom factor by getting {Exif}dictionary's DigitalZoomRatio
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
    NSString *pictureZoomFactor = [[metadata objectForKey:@"{Exif}"] objectForKey:@"DigitalZoomRatio"];    
    NSLog(@"DigitalZoomRatio is in %@", pictureZoomFactor);

// Converts both Zooms to number & multiplies together for TOTAL zoom factor
    secondZoomFactor = [pictureZoomFactor floatValue];
// keeps zoom factor from being zero
    if (!secondZoomFactor) {
        // NSLog (@"No zoom factor");
        secondZoomFactor = 1.0;
    }    
    totalZoomFactor = zoomFactor *secondZoomFactor;
    NSString *finalZoomFactor = [[NSString alloc] initWithFormat:@"Total zoom = %3.1f", totalZoomFactor];
    self.myAssistantLabel.text = finalZoomFactor;
    // NSLog(@"zoom are %2.3f, %2.3f, %2.3f", zoomFactor, secondZoomFactor, totalZoomFactor);
    
// Calculates actual distance in selected units
    float distance = totalZoomFactor * flagHeight * FUTZ_FACTOR;
    self.distanceLabel.text = [NSString stringWithFormat:@"%3.0f %@ away", distance, distanceUnits];

// gets rid of the image controller modal view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel method");
    [self dismissModalViewControllerAnimated:YES];

}

@end
