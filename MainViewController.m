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
    NSNumber *distance;
    UIImageView *reticleView;
    UIImagePickerController *imagePickerController;
    NSString *distanceUnits;
    
}
// @synthesize helpView = _helpView;

#define FUTZ_FACTOR 6.0

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
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
<<<<<<< HEAD
    */

    CGRect frame = CGRectMake(130.0, 150.0, 60.0, 120.0);
    reticleView = [[UIImageView alloc] initWithFrame:frame];
    reticleView.image = [UIImage imageNamed:@"dwg06.png"];
    reticleView.userInteractionEnabled = YES;
=======
// Builds a view to overlay over the camera view including the zoom factor
//<<<<<<< HEAD:MainViewController.m
    CGRect frame = CGRectMake(80.0, 150.0, 160.0, 120.0);
    //CGRect frame = CGRectMake(130.0, 150.0, 60.0, 120.0);
    //self.reticleView = [[UIImageView alloc] initWithFrame:frame];
    //self.reticleView.image = [UIImage imageNamed:@"dwg06.png"];
    reticleView = [[UIImageView alloc] initWithFrame:frame];
    reticleView.image = [UIImage imageNamed:@"scope.png"];
//=======
   // CGRect frame = CGRectMake(10.0, 40.0, 320.0, 240.0);
    //CGRect frame = CGRectMake(100.0, 100.0, 200.0, 200.0);
   // self.reticleView = [[UIImageView alloc] initWithFrame:frame];
    //self.reticleView.image = [UIImage imageNamed:@"scope.png"];
  //  self.reticleView.image = [UIImage imageNamed:@"dwg06.png"];
//>>>>>>> 262514d0c77a08c21caa6d57f6ae6ff8290bb89e:RangeFinder/MainViewController.m
//    self.reticleView.inputView.subviews
//    self.reticleView.backgroundColor = [UIColor blueColor];
//    self.reticleView.alpha = 0.65;
    //self.reticleView.userInteractionEnabled = YES;
    reticleView.userInteractionEnabled = YES;

    self.helpView.hidden = YES;

// Sets up the view's values & displays
//    self.myAssistantLabel.hidden = NO;
>>>>>>> ae17683cdc8cfe1853284fc7f54b6fef988504d7
    
// Sets up the distance label
    self.distanceLabel.text = @"xxx yards";
    
// Builds the slider and rotates it 90 degrees
    CGRect sliderFrame = CGRectMake(-120.0, 150.0,300.0, 50.0);
    self.reticleZoomSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
    self.reticleZoomSlider.transform = trans;
    [self.reticleView addSubview:self.reticleZoomSlider];
    
    UIViewController *upperVC = self.presentingViewController;
}

-(BOOL)shouldAutorotate{
    return NO;
}

<<<<<<< HEAD
=======
-(NSUInteger)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Custom Methods

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

>>>>>>> ae17683cdc8cfe1853284fc7f54b6fef988504d7
#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
// sets myAssistantLabel ON/OFF
    if (controller.helpSwitch.on) {
        self.myAssistantLabel.hidden = NO;
    } else {
        self.myAssistantLabel.hidden = YES;
    }
    self.myAssistantLabel.text = controller.flipsideInfo.text;
    [self dismissModalViewControllerAnimated:YES];
    flagHeight = [controller.flipsideInfo.text floatValue];
    NSLog(@"FlagHeight is %3.3f", flagHeight);
    //self.distanceUnits = controller.flagUnits;
    distanceUnits = controller.flagUnits;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:(id)self];
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
    
    // Calculates actual distance in yards
<<<<<<< HEAD
    self.distanceLabel.text = [NSString stringWithFormat:@"%3.0f %@", (totalZoomFactor * flagHeight * FUTZ_FACTOR), distanceUnits];
=======
    //self.distanceLabel.text = [NSString stringWithFormat:@"%3.0f %@", (totalZoomFactor * flagHeight * FUTZ_FACTOR), self.distanceUnits];
    self.distanceLabel.text = [NSString stringWithFormat:@"%4.0f %@", (totalZoomFactor * flagHeight * FUTZ_FACTOR), distanceUnits];
>>>>>>> ae17683cdc8cfe1853284fc7f54b6fef988504d7

// gets rid of the image controller modal view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel method");
    [self dismissModalViewControllerAnimated:YES];

}

@end
