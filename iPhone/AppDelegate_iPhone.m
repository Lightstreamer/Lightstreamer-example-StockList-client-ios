//
//  AppDelegate_iPhone.m
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

#import "AppDelegate_iPhone.h"
#import "StockListViewController.h"
#import "Constants.h"


@implementation AppDelegate_iPhone


#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    application.statusBarStyle= UIStatusBarStyleLightContent;
	
	// Create the user interface
	_stockListController= [[StockListViewController alloc] init];
	
	_navController= [[UINavigationController alloc] initWithRootViewController:_stockListController];
	_navController.navigationBar.barStyle= UIBarStyleBlack;

	_window.rootViewController= _navController;
    [_window makeKeyAndVisible];

    return YES;
}


#pragma mark -
#pragma mark Properties

@synthesize window= _window;
@synthesize stockListController= _stockListController;


@end
