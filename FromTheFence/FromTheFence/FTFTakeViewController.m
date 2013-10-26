//
//  FTFSecondViewController.m
//  FromTheFence
//
//  Created by Nick LaGrow on 10/26/13.
//  Copyright (c) 2013 nlagrow.pmarino. All rights reserved.
//

#import "FTFTakeViewController.h"

@interface FTFTakeViewController () <UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation FTFTakeViewController

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
  NSInteger ti = (NSInteger)interval;
  NSInteger seconds = ti % 60;
  NSInteger minutes = (ti / 60) % 60;
  NSInteger hours = (ti / 3600);
  return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.orgText.delegate = self;
  self.orgName.delegate = self;
  PFQuery *query = [PFQuery queryWithClassName:@"Current"];
  
  [query getObjectInBackgroundWithId:@"f4FKOhHYUC" block:^(PFObject *current, NSError *error) {
    if (!error) {
      NSDate *lastTaken = current.updatedAt;
      NSTimeInterval timeSinceLast = [[NSDate date] timeIntervalSinceDate:lastTaken];
      
      if (timeSinceLast > 24*60*60) {
        self.timeRemaining = 0;
      } else {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: today];
        [components setHour: 0];
        [components setMinute: 0];
        [components setSecond: 0];
        
        NSDate *newDate = [gregorian dateFromComponents: components];
        NSDate *tomorrow = [newDate dateByAddingTimeInterval:60*60*24*1];
        //tomorrow = [tomorrow dateByAddingTimeInterval:-1*60*60*4];
        NSLog(@"%@", tomorrow);
        
        self.timeRemaining = [tomorrow timeIntervalSinceDate:today];
      }
      self.timeRemaining = 0;
      self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
      self.timeRemainingLabel.text = [self stringFromTimeInterval:self.timeRemaining];
    }
  }];
  
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
  [aTextField resignFirstResponder];
  return YES;
}

- (IBAction)takeFence:(id)sender {
  if (self.timeRemaining > 0) {
    return;
  } else {
    PFQuery *query_current = [PFQuery queryWithClassName:@"Current"];
    
    [query_current getObjectInBackgroundWithId:@"f4FKOhHYUC" block:^(PFObject *current, NSError *error) {
      if (!error) {
        [current setObject:self.orgName.text forKey:@"orgName"];
        [current setObject:self.orgText.text forKey:@"orgMessage"];
        [current saveInBackground];
      }
    }];
    
    PFQuery *query_history = [PFQuery queryWithClassName:@"History"];
    
    [query_history findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if(!error && [objects count] > 0) {
        PFObject *obj = [objects objectAtIndex:0];
        if ([obj[@"orgName"] isEqualToString:self.orgName.text]){
          return;
        }
      }
      
      PFObject *newObject = [PFObject objectWithClassName:@"History"];
      [newObject setObject:self.orgName.text forKey:@"orgName"];
      [newObject setObject:self.orgText.text forKey:@"orgMessage"];
      [newObject saveInBackground];
    }];
  }
}

- (IBAction)takePicture:(id)sender {
  [self startCameraControllerFromViewController: self
                                  usingDelegate: self];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
  
  if (([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypeCamera] == NO)
      || (delegate == nil)
      || (controller == nil)) {
    return NO;
  }
  
  
  UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
  cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  // Displays a control that allows the user to choose picture or
  // movie capture, if both are available:
  cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
  
  // Hides the controls for moving & scaling pictures, or for
  // trimming movies. To instead show the controls, use YES.
  cameraUI.allowsEditing = NO;
  
  cameraUI.delegate = delegate;
  
  [controller presentModalViewController: cameraUI animated: YES];
  return YES;
}

- (void) updateTimer:(NSTimer *)timer {
  if (self.timeRemaining > 0) {
    self.timeRemaining = self.timeRemaining - 1;
    self.timeRemainingLabel.text = [self stringFromTimeInterval:self.timeRemaining];
  } else {
    [self.timer invalidate];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
  
  [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
  
  NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
  UIImage *originalImage, *editedImage, *imageToSave;
  
  // Handle a still image capture
  if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
      == kCFCompareEqualTo) {
    
    editedImage = (UIImage *) [info objectForKey:
                               UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage) {
      imageToSave = editedImage;
    } else {
      imageToSave = originalImage;
    }
    
    // Save the new image (original or edited) to the Camera Roll
    UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
  }
}

@end
