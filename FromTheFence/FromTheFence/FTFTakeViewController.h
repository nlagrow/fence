//
//  FTFSecondViewController.h
//  FromTheFence
//
//  Created by Nick LaGrow on 10/26/13.
//  Copyright (c) 2013 nlagrow.pmarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface FTFTakeViewController : UIViewController
  @property (strong, nonatomic) IBOutlet UILabel *timeRemainingLabel;
  @property (nonatomic) NSTimeInterval timeRemaining;
  @property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UITextView *orgText;
@property (strong, nonatomic) IBOutlet UITextField *orgName;

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (IBAction)takeFence:(id)sender;
- (IBAction)takePicture:(id)sender;

@end
