//
//  SettingsController.m
//  CheckMobi
//
//  Created by CheckMobi on 2/1/15.
//  Copyright (c) 2015 CheckMobi.com. All rights reserved.
//

#import "SettingsController.h"
#import "CheckMobiService.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (void)viewDidLoad
{
    [self.baseUrlField setText:[[CheckMobiService sharedInstance] baseUrl]];
    [self.smsLanguageField setText:[[CheckMobiService sharedInstance] smsLanguage]];
    [self.ivrLanguageField setText:[[CheckMobiService sharedInstance] ivrLanguage]];
    [self.secretKeyField setText:[[CheckMobiService sharedInstance] secretKey]];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender
{
    if(self.baseUrlField.text.length == 0 || self.secretKeyField.text.length == 0)
    {
        UIAlertView * alertView = [[UIAlertView alloc]  initWithTitle:@"Error"
                                                              message:@"Secret key and base url are empty!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [[CheckMobiService sharedInstance] setBaseUrl:self.baseUrlField.text];
    [[CheckMobiService sharedInstance] setSecretKey:self.secretKeyField.text];
    [[CheckMobiService sharedInstance] setSmsLanguage:self.smsLanguageField.text];
    [[CheckMobiService sharedInstance] setIvrLanguage:self.ivrLanguageField.text];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.baseUrlField text] forKey:@"base_url"];
    [defaults setObject:[self.secretKeyField text] forKey:@"secret_key"];
    [defaults setObject:[self.ivrLanguageField text] forKey:@"ivr_lang"];
    [defaults setObject:[self.smsLanguageField text] forKey:@"sms_lang"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
