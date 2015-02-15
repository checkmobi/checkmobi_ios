//
//  ViewController.h
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *validationType;
@property (weak, nonatomic) IBOutlet UITextField *validationNumber;
@property (weak, nonatomic) IBOutlet UITextField *validationPin;
@property (weak, nonatomic) IBOutlet UIButton *validationButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *callChargeLabel;

- (IBAction)OnValidate:(id)sender;
- (IBAction)OnValidationTypeChanged:(id)sender;
- (IBAction)OnReset:(id)sender;

@end
