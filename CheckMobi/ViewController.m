//
//  ViewController.m
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import "ViewController.h"
#import "CheckMobiService.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

inline static void ShowMessageBox(NSString * title , NSString *message, NSInteger tag, id delegate)
{
    UIAlertView * alertView = [[UIAlertView alloc]  initWithTitle:title
                                                    message:message
                                                    delegate:delegate
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    [alertView setTag:tag];
    [alertView show];
}

@interface ViewController ()

@property (nonatomic, strong) NSString* callId;
@property (nonatomic, strong) NSString* dialingNumber;
@property (nonatomic, strong) NSString* validationKey;
@property (nonatomic, assign) bool pinStep;
@property (nonatomic, strong) CTCallCenter* callCenter;

- (void) HandleValidationServiceError:(NSInteger) http_status withBody:(NSDictionary*) body withError:(NSError*) error;
- (void) RefreshGUI;
- (enum ValidationType) GetCurrentValidationType;
- (void) PerformCliValidation:(NSString*) key withDestinationNr:(NSString*) desination_number;
- (void) PerformPinValidation:(NSString*) key;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckCallState) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [super viewDidLoad];
    [self registerForCalls];
    [self RefreshGUI];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) CheckCallState
{
    if(self.dialingNumber == nil || self.validationKey == nil || self.callId == nil)
        return;

    bool found = false;
    
    CTCallCenter* center = [[CTCallCenter alloc] init];
    
    if (center.currentCalls != nil)
    {
        NSArray* currentCalls = [center.currentCalls allObjects];

        for (CTCall *call in currentCalls)
        {
            if([call.callID isEqualToString:self.callId])
            {
                found = true;
                break;
            }
        }
    }
    
    if(!found)
        [self CallCompleted:self.callId];
}
    

- (void) CallInitiated:(NSString*) callid
{
    if(self.dialingNumber == nil || self.validationKey == nil || self.callId != nil)
        return;
    
    self.callId = callid;
}

- (void) CallCompleted:(NSString*) call_id
{
    if(self.dialingNumber == nil || self.validationKey == nil || self.callId == nil)
        return;
    
    if(![self.callId isEqualToString:call_id])
        return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[CheckMobiService sharedInstance] CheckValidationStatus:self.validationKey withResponse:^(NSInteger status, NSDictionary *result, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         self.dialingNumber = nil;
         self.validationKey = nil;
         self.callId = nil;
         
         if(status == kStatusSuccessWithContent && result != nil)
         {
             NSNumber *validated = [result objectForKey:@"validated"];
             
             if(![validated boolValue])
             {
                 ShowMessageBox(@"Error", @"Number not validated ! Check your phone number!" , 0, nil);
                 return;
             }
             
             ShowMessageBox(@"Validation completed", [NSString stringWithFormat:@"Validation completed for: %@", self.validationNumber.text] , 0, nil);
             [self OnReset:nil];
         }
         else
         {
             [self HandleValidationServiceError:status withBody:result withError:error];
         }
     }];
}

- (void) registerForCalls
{
    self.callCenter = [[CTCallCenter alloc] init];
    __weak typeof(self) weakSelf = self;

    [self.callCenter setCallEventHandler: ^(CTCall* call)
    {
        NSLog(@"CallEventHandler: %@", call.callState);
        
        if ([call.callState isEqualToString: CTCallStateDialing])
            [weakSelf performSelectorOnMainThread:@selector(CallInitiated:) withObject:call.callID waitUntilDone:NO];
        else if ([call.callState isEqualToString: CTCallStateDisconnected])
            [weakSelf performSelectorOnMainThread:@selector(CallCompleted:) withObject:call.callID waitUntilDone:NO];
    }];
}

- (enum ValidationType) GetCurrentValidationType
{
    NSInteger selected = self.validationType.selectedSegmentIndex;
    
    if(selected == 0)
        return ValidationTypeCLI;
    else if(selected == 1)
        return ValidationTypeSMS;
    else if(selected == 2)
        return ValidationTypeIVR;
    
    return ValidationTypeReverseCLI;
}

- (IBAction)OnValidate:(id)sender
{
    if([[CheckMobiService sharedInstance] secretKey] == nil)
    {
        ShowMessageBox(@"Error", @"API secret key is not specified", 0, nil);
        return;
    }
    
    if(![[Reachability reachabilityForInternetConnection] isReachable])
    {
        ShowMessageBox(@"Error", @"No internet connection available!", 0, nil);
        return;
    }
    
    if(!self.pinStep)
    {
        if(self.validationNumber.text.length == 0)
        {
            ShowMessageBox(@"Invalid number", @"Please provide a valid number", 0, nil);
            return;
        }
        
        [self.validationNumber resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[CheckMobiService sharedInstance] RequestValidation:[self GetCurrentValidationType] forNumber:self.validationNumber.text withResponse:^(NSInteger status, NSDictionary* result, NSError* error)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"status= %ld result=%@", (long)status, result);
            
            if(status == kStatusSuccessWithContent && result != nil)
            {
                NSString* key = [result objectForKey:@"id"];
                NSString* type = [result objectForKey:@"type"];
                
                self.validationNumber.text = [[result objectForKey:@"validation_info"] objectForKey:@"formatting"];
                
                if([type isEqualToString:kValidationStringCLI])
                    [self PerformCliValidation:key withDestinationNr:[result objectForKey:@"dialing_number"]];
                else
                    [self PerformPinValidation:key];
            }
            else
            {
                [self HandleValidationServiceError:status withBody:result withError:error];
            }
            
        }];
    }
    else
    {
        if(self.validationPin.text.length == 0)
        {
            ShowMessageBox(@"Invalid pin", @"Please provide a valid pin number", 0, nil);
            return;
        }
        
        [self.validationPin resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[CheckMobiService sharedInstance] VerifyPin:self.validationKey withPin:self.validationPin.text withResponse:^(NSInteger status, NSDictionary * result, NSError* error)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if(status == kStatusSuccessWithContent && result != nil)
            {
                NSNumber *validated = [result objectForKey:@"validated"];
                
                if(![validated boolValue])
                {
                    ShowMessageBox(@"Error", @"Invalid PIN!" , 0, nil);
                    return;
                }
                
                ShowMessageBox(@"Validation completed", [NSString stringWithFormat:@"Validation completed for: %@", self.validationNumber.text] , 0, nil);
                [self OnReset:nil];
            }
            else
            {
                [self HandleValidationServiceError:status withBody:result withError:error];
            }
        }];
        
    }
}

- (void) PerformCliValidation:(NSString*) key withDestinationNr:(NSString*) desination_number
{
    self.validationKey = key;
    self.dialingNumber = desination_number;
    
    NSString *phoneURLString = [NSString stringWithFormat:@"telprompt://%@", desination_number];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    [[UIApplication sharedApplication] openURL:phoneURL];
}

- (void) PerformPinValidation:(NSString*) key
{
    self.validationKey = key;
    self.pinStep = true;
    [self RefreshGUI];
}

- (IBAction)OnValidationTypeChanged:(id)sender
{
    [self RefreshGUI];
}

- (IBAction)OnReset:(id)sender
{
    self.callId = nil;
    self.dialingNumber = nil;
    self.validationKey = nil;
    self.pinStep = false;
    self.validationPin.text = @"";
    self.validationNumber.text = @"";
    [self RefreshGUI];
}

- (void) HandleValidationServiceError:(NSInteger) http_status withBody:(NSDictionary*) body withError:(NSError*) error
{
    NSLog(@"HandleValidationServiceError: status= %d body: %@ error: %@", (int) http_status, body, error);
    
    if(body)
    {
        NSString *error_message;
        enum ErrorCode error = (enum ErrorCode)[[body valueForKey:@"code"] intValue];
        
        switch (error)
        {
            case ErrorCodeInvalidPhoneNumber:
                error_message = @"Invalid phone number. Please provide the number in E164 format.";
                break;
                
            default:
                error_message = @"Service unavailable. Please try later.";
        }
        
        ShowMessageBox(@"Error", error_message, 0, nil);
    }
    else
        ShowMessageBox(@"Error", @"Service unavailable. Please try later.", 0, nil);
}

- (void) RefreshGUI
{
    if(self.pinStep)
        [self.validationButton setTitle:@"Submit PIN" forState:UIControlStateNormal];
    else
        [self.validationButton setTitle:@"Validate" forState:UIControlStateNormal];
    
    self.validationNumber.enabled = !self.pinStep;
    self.validationType.enabled = !self.pinStep;
    self.validationPin.hidden = !self.pinStep;
    self.resetButton.hidden = !self.pinStep;
    self.callChargeLabel.hidden = (self.validationType.selectedSegmentIndex != 0);
}


@end
