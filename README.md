### checkmobi_ios SDK - Objective C version

#### This project is deprecated. You can use the new [Remote Config SDK][1] to integrate CheckMobi into any iOS App.

In order to use the sample to test the CheckMobi service you need to set the API key using 
`[[CheckMobiService sharedInstance] setSecretKey:@"secret_key_here"];`

Probably the best place to do this is in 

`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`

As an alternative you can complete this key into the settings dialog.

In `ViewController.m` there are two options that you can play with:

- `const bool kHangupFirstCallDuringReverseCli = true;` used to hangup the first incoming call during the missed call verification.
This one minimise the chance to have the call answered by the end user. 

- `const bool kShowCheckmobiDetailedMessages = true;` show/hide debug informations that might not be useful for end user. 

[1]:https://github.com/checkmobi/remote-config-sdk-ios
