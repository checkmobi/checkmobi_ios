//
//  AppDelegate.m
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckMobiService.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//is mandatory to set the API secret key that you can find into your account settings
	//use [[CheckMobiService sharedInstance] setSecretKey:@"secret_key_here"];
	//or go in settings view in this sample and paste it there.
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* base_url = [defaults objectForKey:@"base_url"];
    NSString* secret_key = [defaults objectForKey:@"secret_key"];
    NSString* sms_lang = [defaults objectForKey:@"sms_lang"];
    NSString* ivr_lang = [defaults objectForKey:@"ivr_lang"];
    
    if([base_url length] > 0)
        [[CheckMobiService sharedInstance] setBaseUrl:base_url];
    
    if([secret_key length] > 0)
        [[CheckMobiService sharedInstance] setSecretKey:secret_key];

    if([sms_lang length] > 0)
        [[CheckMobiService sharedInstance] setSmsLanguage:sms_lang];

    if([ivr_lang length] > 0)
        [[CheckMobiService sharedInstance] setIvrLanguage:ivr_lang];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
 
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
