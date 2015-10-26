//
//  AppDelegate_iPad.m
//  StockList Demo for iOS
//
// Copyright (c) Lightstreamer Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "AppDelegate_iPad.h"
#import "StockListViewController.h"
#import "DetailViewController.h"
#import "Constants.h"


@implementation AppDelegate_iPad


#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle= UIStatusBarStyleLightContent;
	
	// Uncomment for detailed logging
//	[LSLog enableSourceType:LOG_SRC_CLIENT];
//	[LSLog enableSourceType:LOG_SRC_SESSION];
//	[LSLog enableSourceType:LOG_SRC_STATE_MACHINE];
//	[LSLog enableSourceType:LOG_SRC_URL_DISPATCHER];

	// Create the user interface
	_stockListController= [[StockListViewController alloc] init];
	
	UINavigationController *navController1= [[UINavigationController alloc] initWithRootViewController:_stockListController];
	navController1.navigationBar.barStyle= UIBarStyleBlack;

	_detailController= [[DetailViewController alloc] init];
	
	UINavigationController *navController2= [[UINavigationController alloc] initWithRootViewController:_detailController];
	navController2.navigationBar.barStyle= UIBarStyleBlack;

	_splitController= [[UISplitViewController alloc] init];
	[_splitController setViewControllers:[NSArray arrayWithObjects:navController1, navController2, nil]];
	
	_window.rootViewController= _splitController;
    [_window makeKeyAndVisible];
	
    return YES;
}


#pragma mark -
#pragma mark Properties

@synthesize window= _window;
@synthesize stockListController= _stockListController;
@synthesize detailController= _detailController;


@end
