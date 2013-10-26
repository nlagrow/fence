//
//  FTFFirstViewController.h
//  FromTheFence
//
//  Created by Nick LaGrow on 10/26/13.
//  Copyright (c) 2013 nlagrow.pmarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FTFHomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *currentOrgLabel;
@property (strong, nonatomic) IBOutlet UITextView *currentOrgText;
@property (strong, nonatomic) IBOutlet UIImageView *currentOrgImage;

@end
