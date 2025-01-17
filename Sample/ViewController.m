//
//  ViewController.m
//  RewardBasedVideo
//
//  Created by Imran Khan on 2/9/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

@import GoogleMobileAds;

#import <VungleSDK/VungleSDK.h>

#import "VungleAdNetworkExtras.h"

#import "ViewController.h"
#import "OptionsViewController.h"

static NSString *const kRequestMessage = @"Request RewardBased ad from vungle.";
static NSString *const kPresentMessage = @"Present RewardBased ad from vungle.";

static NSString *const kRequestInterstitialMessage = @"Request Interstitial ad from vungle.";
static NSString *const kPresentInterstitialMessage = @"Present Interstitial ad from vungle.";

static NSString *const UnitIDrewardBased = @"ca-app-pub-3940256099942544/9998782919";//rewardBasedVideo

static NSString *const UnitIDInterstitial = @"ca-app-pub-1812018162342166/7341265538";//Interstitial

@interface ViewController () <GADRewardBasedVideoAdDelegate, GADInterstitialDelegate>
@property(nonatomic, assign) BOOL interstitialAdReceivedFromVungle;
@property(nonatomic, assign) BOOL adReceivedFromVungle;
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self appendLog:[NSString stringWithFormat:@"App version: %@", appVersion]];
    [self appendLog:[NSString stringWithFormat:@"Reward based adapter: %@", [self versionOfAdapter:@"GADMAdapterVungleRewardBasedVideoAd"]]];
    [self appendLog:[NSString stringWithFormat:@"Interstitial adapter: %@", [self versionOfAdapter:@"GADMAdapterVungleInterstitial"]]];
    [self appendLog:[NSString stringWithFormat:@"AdMob SDK: %@", [GADRequest sdkVersion]]];
    [self appendLog:[NSString stringWithFormat:@"Vungle SDK: %@", VungleSDKVersion]];

    [GADRewardBasedVideoAd sharedInstance].delegate = self;

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                 kVungleOptionUserId: @"vungle_user",
                                 kVungleOptionMuted: @NO
                                 }];

}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSString *)versionOfAdapter:(NSString *)className {
    Class class = NSClassFromString(className);
    SEL selector = NSSelectorFromString(@"adapterVersion");
    if ([class respondsToSelector:selector])
        return ((NSString * (*)(id, SEL))[class methodForSelector:selector])(class, selector);
    else
        return nil;
}

- (void)appendLog:(NSString *)text {
    if (self.logView.text.length)
        self.logView.text = [NSString stringWithFormat:@"%@\n%@", self.logView.text, text];
    else
        self.logView.text = text;
    [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
}

- (VungleAdNetworkExtras *)adNetworkExtras {
    VungleAdNetworkExtras *extras = [[VungleAdNetworkExtras alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    extras.userId = [defaults stringForKey:kVungleOptionUserId];
    extras.muted = [defaults boolForKey:kVungleOptionMuted];
    return extras;
}

#pragma mark RewardBasedVideoAd

- (void)resetRequest {
  _adReceivedFromVungle = NO;
  [_RBVVungleButton setTitle:kRequestMessage forState:UIControlStateNormal];
}

- (void)onRequestRBVFromVungle:(id)sender {
	if (_adReceivedFromVungle) {
		[[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
	} else {
		[self resetRequest];
		GADRequest *request = [GADRequest request];
		[request registerAdNetworkExtras:[self adNetworkExtras]];
		[[GADRewardBasedVideoAd sharedInstance] loadRequest:request
											   withAdUnitID:UnitIDrewardBased];
        [self appendLog:@"Requesting reward based video ad..."];
	}
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	_adReceivedFromVungle = YES;
	[_RBVVungleButton setTitle:kPresentMessage forState:UIControlStateNormal];
	
	[self appendLog:@"Reward based video ad is received."];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	[self appendLog:@"Opened reward based video ad."];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	[self appendLog:@"Reward based video ad started playing."];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	[self appendLog:@"Reward based video ad is closed."];
	[self resetRequest];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
	NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %@", reward.type, reward.amount];
	[self appendLog:rewardMessage];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	[self appendLog:@"Reward based video ad will leave application."];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
	didFailToLoadwithError:(NSError *)error {
	[self appendLog:@"Reward based video ad failed to load."];
}


#pragma mark InterstitialAd

- (void)resetInterstitialRequest {
	_interstitialAdReceivedFromVungle = NO;
	[_VungleInterstitialButton setTitle:kRequestInterstitialMessage forState:UIControlStateNormal];
}

- (IBAction)onRequestInterstitialFromVungle:(id)sender{
	if (_interstitialAdReceivedFromVungle) {
		[self.interstitial presentFromRootViewController:self];
	} else {
		[self resetInterstitialRequest];
		self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:UnitIDInterstitial];
		self.interstitial.delegate = self;
		GADRequest *request = [GADRequest request];
		[request registerAdNetworkExtras:[self adNetworkExtras]];
		//test ad from admob
		//request.testDevices = @[kGADSimulatorID];
		[self.interstitial loadRequest:request];
        [self appendLog:@"Requesting interstitial ad..."];
	}
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
	_interstitialAdReceivedFromVungle = YES;
	[_VungleInterstitialButton setTitle:kPresentInterstitialMessage forState:UIControlStateNormal];
	
	[self appendLog:@"Interstitial ad is received."];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
	[self appendLog:@"Interstitial ad failed to load."];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad{
	[self appendLog:@"Opened interstitial ad."];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad{
	[self appendLog:@"Interstitial ad is closed."];
	[self resetInterstitialRequest];
}

@end
