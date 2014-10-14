//
//  AppDelegate_iPad.h
//  StockList Demo for iOS
//
// Copyright 2013 Weswit Srl
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

#import <UIKit/UIKit.h>
#import "StockListAppDelegate.h"


@class StockListViewController;
@class DetailViewController;

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate, StockListAppDelegate> {
    UIWindow *_window;
	
	UISplitViewController *_splitController;
	StockListViewController *_stockListController;
	DetailViewController *_detailController;
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, readonly) StockListViewController *stockListController;
@property (nonatomic, readonly) DetailViewController *detailController;


@end

