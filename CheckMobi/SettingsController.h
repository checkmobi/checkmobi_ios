//
//  SettingsController.h
//  CheckMobi
//
//  Created by CheckMobi on 2/1/15.
//  Copyright (c) 2015 CheckMobi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *baseUrlField;
@property (weak, nonatomic) IBOutlet UITextField *secretKeyField;
@property (weak, nonatomic) IBOutlet UITextField *smsLanguageField;
@property (weak, nonatomic) IBOutlet UITextField *ivrLanguageField;

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;

@end
