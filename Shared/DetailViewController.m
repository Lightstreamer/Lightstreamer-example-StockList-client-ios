//
//  DetailViewController.m
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

#import "DetailViewController.h"
#import "DetailView.h"
#import "ChartViewController.h"
#import "StockListAppDelegate.h"
#import "StockListViewController.h"
#import "Connector.h"
#import "SpecialEffects.h"
#import "Constants.h"
#import "UIAlertView+BlockExtensions.h"


#pragma mark -
#pragma mark DetailViewController extension

@interface DetailViewController ()


#pragma mark -
#pragma mark Internals

- (void) updateView;


@end


#pragma mark -
#pragma mark DetailViewController implementation

@implementation DetailViewController


#pragma mark -
#pragma mark Initialization

- (id) init {
	if (self = [super init]) {
		
        // Queue for background execution
		_backgroundQueue= dispatch_queue_create("backgroundQueue", 0);
		
		// Single-item data structures: they store fields data and
		// which fields have been updated
		_itemData= [[NSMutableDictionary alloc] init];
		_itemUpdated= [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


#pragma mark -
#pragma mark Methods of UIViewController

- (void) loadView {
	NSArray *niblets= [[NSBundle mainBundle] loadNibNamed:DEVICE_XIB(@"DetailView") owner:self options:NULL];
	_detailView= (DetailView *) [niblets lastObject];
	
	self.view= _detailView;
	
	// Add chart
	_chartController= [[ChartViewController alloc] init];
	[_chartController.view setBackgroundColor:[UIColor whiteColor]];
	[_chartController.view setFrame:CGRectMake(0.0, 0.0, _detailView.chartBackgroundView.frame.size.width, _detailView.chartBackgroundView.frame.size.height)];
	
	[_detailView.chartBackgroundView addSubview:_chartController.view];
}

- (void) viewWillAppear:(BOOL)animated {
	
	// Reset size of chart
	[_chartController.view setFrame:CGRectMake(0.0, 0.0, _detailView.chartBackgroundView.frame.size.width, _detailView.chartBackgroundView.frame.size.height)];
}

- (void) viewDidDisappear:(BOOL)animated {
	
	// Unsubscribe the table
	if (_tableKey) {
		dispatch_async(_backgroundQueue, ^{
			NSLog(@"DetailViewController: unsubscribing previous table...");
			
			@try {
				[[[Connector sharedConnector] client] unsubscribeTable:_tableKey];
				
				NSLog(@"DetailViewController: previous table unsubscribed");
				
			} @catch (NSException *e) {
				NSLog(@"DetailViewController: previous table unsubscription failed with exception: %@", e);
			}
			
			_tableKey= nil;
		});
	}
}


#pragma mark -
#pragma mark Communication with StockList View Controller

- (void) changeItem:(NSString *)item {
	// This method is always called from the main thread
	
	// Set current item and clear the data
	@synchronized (self) {
		_item= item;
		
		[_itemData removeAllObjects];
		[_itemUpdated removeAllObjects];
	}
	
	// Update the view
	[self updateView];

	// Reset the chart
	[_chartController clearChart];
	
	dispatch_async(_backgroundQueue, ^{

		// If needed, unsubscribe previous table
		if (_tableKey) {
			NSLog(@"DetailViewController: unsubscribing previous table...");
			
			@try {
				[[[Connector sharedConnector] client] unsubscribeTable:_tableKey];
				
				NSLog(@"DetailViewController: previous table unsubscribed");
				
			} @catch (NSException *e) {
				NSLog(@"DetailViewController: previous table unsubscription failed with exception: %@", e);
			}
			
			_tableKey= nil;
		}
		
		// Subscribe new single-item table
		if (item) {
			NSLog(@"DetailViewController: subscribing table...");
			
			@try {
				
				// The LSClient will reconnect and resubscribe automatically
				LSExtendedTableInfo *tableInfo= [LSExtendedTableInfo extendedTableInfoWithItems:[NSArray arrayWithObject:item]
																						   mode:LSModeMerge
																						 fields:DETAIL_FIELDS
																					dataAdapter:DATA_ADAPTER
																					   snapshot:YES];
				
				_tableKey= [[[Connector sharedConnector] client] subscribeTableWithExtendedInfo:tableInfo
																					   delegate:self
																				useCommandLogic:NO];
				
				NSLog(@"DetailViewController: table subscribed");
				
			} @catch (NSException *e) {
				NSLog(@"DetailViewController: table subscription failed with exception: %@", e);
			}
		}
	});
}


#pragma mark -
#pragma mark Methods of LSTableDelegate

- (void) table:(LSSubscribedTableKey *)tableKey itemPosition:(int)itemPosition itemName:(NSString *)itemName didUpdateWithInfo:(LSUpdateInfo *)updateInfo {
	// This method is always called from a background thread
	
	@synchronized (self) {
		
		// Check if it is a late update of the previous table
		if (![_item isEqualToString:itemName])
			return;
		
		// Store the updated fields in the item's data structures
		for (NSString *fieldName in DETAIL_FIELDS) {
			NSString *value= [updateInfo currentValueOfFieldName:fieldName];
			
			if (value)
				[_itemData setObject:value forKey:fieldName];
			else
				[_itemData setObject:[NSNull null] forKey:fieldName];
			
			if ([updateInfo isChangedValueOfFieldName:fieldName])
				[_itemUpdated setObject:[NSNumber numberWithBool:YES] forKey:fieldName];
		}
		
		double currentLastPrice= [[updateInfo currentValueOfFieldName:@"last_price"] doubleValue];
		double previousLastPrice= [[updateInfo previousValueOfFieldName:@"last_price"] doubleValue];
		if (currentLastPrice >= previousLastPrice)
			[_itemData setObject:@"green" forKey:@"color"];
		else
			[_itemData setObject:@"orange" forKey:@"color"];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{

		// Forward the update to the chart
		[_chartController itemDidUpdateWithInfo:updateInfo];
		
		// Update the view
		[self updateView];
	});
}


#pragma mark -
#pragma mark Properties

@synthesize item= _item;


#pragma mark -
#pragma mark Internals

- (void) updateView {
	// This method is always called on the main thread
	
	@synchronized (self) {

		// Take current item status from item's data structures
		// and update the view appropriately
		NSString *colorName= [_itemData objectForKey:@"color"];
		UIColor *color= nil;
		if ([colorName isEqualToString:@"green"])
			color= GREEN_COLOR;
		else if ([colorName isEqualToString:@"orange"])
			color= ORANGE_COLOR;
		else
			color= [UIColor whiteColor];

		self.title= [_itemData objectForKey:@"stock_name"];
		
		_detailView.lastLabel.text= [_itemData objectForKey:@"last_price"];
		if ([[_itemUpdated objectForKey:@"last_price"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.lastLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"last_price"];
		}
		
		_detailView.timeLabel.text= [_itemData objectForKey:@"time"];
		if ([[_itemUpdated objectForKey:@"time"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.timeLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"time"];
		}
		
		double pctChange= [[_itemData objectForKey:@"pct_change"] doubleValue];
		if (pctChange > 0.0)
			_detailView.dirImage.image= [UIImage imageNamed:@"Arrow-up.png"];
		else if (pctChange < 0.0)
			_detailView.dirImage.image= [UIImage imageNamed:@"Arrow-down.png"];
		else
			_detailView.dirImage.image= nil;
		
		_detailView.changeLabel.text= [[_itemData objectForKey:@"pct_change"] stringByAppendingString:@"%"];
		_detailView.changeLabel.textColor= (([[_itemData objectForKey:@"pct_change"] doubleValue] >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR);
		
		if ([[_itemUpdated objectForKey:@"pct_change"] boolValue]) {
			[SpecialEffects flashImage:_detailView.dirImage withColor:color];
			[SpecialEffects flashLabel:_detailView.changeLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"pct_change"];
		}
			
		_detailView.minLabel.text= [_itemData objectForKey:@"min"];
		if ([[_itemUpdated objectForKey:@"min"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.minLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"min"];
		}
		
		_detailView.maxLabel.text= [_itemData objectForKey:@"max"];
		if ([[_itemUpdated objectForKey:@"max"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.maxLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"max"];
		}
		
		_detailView.bidLabel.text= [_itemData objectForKey:@"bid"];
		if ([[_itemUpdated objectForKey:@"bid"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.bidLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"bid"];
		}
		
		_detailView.askLabel.text= [_itemData objectForKey:@"ask"];
		if ([[_itemUpdated objectForKey:@"ask"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.askLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"ask"];
		}
		
		_detailView.bidSizeLabel.text= [_itemData objectForKey:@"bid_quantity"];
		if ([[_itemUpdated objectForKey:@"bid_quantity"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.bidSizeLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"bid_quantity"];
		}
		
		_detailView.askSizeLabel.text= [_itemData objectForKey:@"ask_quantity"];
		if ([[_itemUpdated objectForKey:@"ask_quantity"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.askSizeLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"ask_quantity"];
		}

		_detailView.openLabel.text= [_itemData objectForKey:@"open_price"];
		if ([[_itemUpdated objectForKey:@"open_price"] boolValue]) {
			[SpecialEffects flashLabel:_detailView.openLabel withColor:color];
			[_itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"open_price"];
		}
	}
}


@end
