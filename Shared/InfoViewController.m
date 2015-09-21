//
//  InfoViewController.m
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

#import "InfoViewController.h"
#import "InfoView.h"
#import "Constants.h"


@implementation InfoViewController


#pragma mark -
#pragma mark Initialization

- (id) init {
	if (self = [super init]) {
		self.title= @"Info";
	}
	
	return self;
}


#pragma mark -
#pragma mark User actions

- (IBAction) linkTapped {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.lightstreamer.com/"]];
}


#pragma mark -
#pragma mark Methods of UIViewController

- (void) loadView {
	NSArray *niblets= [[NSBundle mainBundle] loadNibNamed:DEVICE_XIB(@"InfoView") owner:self options:NULL];
	_infoView= (InfoView *) [niblets lastObject];
	
	self.view= _infoView;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL) shouldAutorotate {
	return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}


@end
