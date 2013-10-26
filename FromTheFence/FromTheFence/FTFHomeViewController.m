//
//  FTFFirstViewController.m
//  FromTheFence
//
//  Created by Nick LaGrow on 10/26/13.
//  Copyright (c) 2013 nlagrow.pmarino. All rights reserved.
//

#import "FTFHomeViewController.h"

@interface FTFHomeViewController ()<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation FTFHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
  if (![PFUser currentUser]) { // No user logged in
                               // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:nil];
  }
  
  PFQuery *query = [PFQuery queryWithClassName:@"Current"];
  
    [query getObjectInBackgroundWithId:@"f4FKOhHYUC" block:^(PFObject *current, NSError *error) {
      if (!error) {
        // Do something with the returned PFObject in the gameScore variable.
        self.currentOrgLabel.text = current[@"orgName"];
        self.currentOrgText.text = current[@"orgMessage"];
        [current[@"orgImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
          if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [self.currentOrgImage setImage: image];
          }
        }];
        NSLog(@"%@", current.updatedAt);
      }
    }];
}

#pragma mark -
#pragma mark PFLoginViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password
{
  // Check if both fields are completed
  if (username && password && username.length != 0 && password.length != 0) {
    return YES; // Begin login process
  }
  
  [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                              message:@"Make sure you fill out all of the information!"
                             delegate:nil
                    cancelButtonTitle:@"ok"
                    otherButtonTitles:nil] show];
  return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark PFSignUpViewControllerDelegate
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info
{
  BOOL informationComplete = YES;
  
  // loop through all of the submitted data
  for (id key in info) {
    NSString *field = [info objectForKey:key];
    if (!field || field.length == 0) { // check completion
      informationComplete = NO;
      break;
    }
  }
  
  // Display an alert if a field wasn't completed
  if (!informationComplete) {
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
  }
  
  return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
  [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
  NSLog(@"Failed to sign up...");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
