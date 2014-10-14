//
//  StockListViewController.m
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

#import "StockListViewController.h"
#import "StockListView.h"
#import "StockListCell.h"
#import "DetailViewController.h"
#import "InfoViewController.h"
#import "StatusViewController.h"
#import "Connector.h"
#import "SpecialEffects.h"
#import "Constants.h"
#import "AppDelegate_iPad.h"
#import "UIAlertView+BlockExtensions.h"


#pragma mark -
#pragma mark StockListViewController extension

@interface StockListViewController ()


#pragma mark -
#pragma mark User actions

- (void) infoTapped;
- (void) statusTapped;


#pragma mark -
#pragma mark Lightstreamer connection status management

- (void) connectionStatusChanged;
- (void) connectionEnded;


#pragma mark -
#pragma mark Internals

- (void) reloadTableRows;


@end


#pragma mark -
#pragma mark StockListViewController implementation

@implementation StockListViewController


#pragma mark -
#pragma mark Initialization

- (id) init {
	if (self = [super init]) {
		self.title= @"Lightstreamer Stock List";
		
        // Queue for background execution
		_backgroundQueue= dispatch_queue_create("backgroundQueue", 0);

		// Multiple-item data structures: each item has a second-level dictionary.
		// They store fields data and which fields have been updated
		_itemData= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_ITEMS];
		_itemUpdated= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_ITEMS];

		// List of rows marked to be reloaded by the table
		_rowsToBeReloaded= [[NSMutableSet alloc] initWithCapacity:NUMBER_OF_ITEMS];
	}
	
	return self;
}


#pragma mark -
#pragma mark User actions

- (void) infoTapped {
	if (DEVICE_IPAD) {
		
		// If the Info popover is open close it
		if (_popoverInfoController) {
            [_popoverInfoController dismissPopoverAnimated:YES];
            _popoverInfoController= nil;
			return;
        }
		
		// If the Status popover is open close it
		if (_popoverStatusController) {
			[_popoverStatusController dismissPopoverAnimated:YES];
            _popoverStatusController= nil;
        }

		// Open the Info popover
		InfoViewController *infoController= [[InfoViewController alloc] init];
		_popoverInfoController= [[UIPopoverController alloc] initWithContentViewController:infoController];
		
		_popoverInfoController.popoverContentSize= CGSizeMake(INFO_IPAD_WIDTH, INFO_IPAD_HEIGHT);
		_popoverInfoController.delegate= self;
		
		[_popoverInfoController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	} else {
		InfoViewController *infoController= [[InfoViewController alloc] init];
		[self.navigationController pushViewController:infoController animated:YES];
	}
}

- (void) statusTapped {
	if (DEVICE_IPAD) {
		
		// If the Status popover is open close it
		if (_popoverStatusController) {
            [_popoverStatusController dismissPopoverAnimated:YES];
            _popoverStatusController= nil;
			return;
        }
		
		// If the Info popover is open close it
		if (_popoverInfoController) {
            [_popoverInfoController dismissPopoverAnimated:YES];
            _popoverInfoController= nil;
        }

		// Open the Status popover
		StatusViewController *statusController= [[StatusViewController alloc] init];
		_popoverStatusController= [[UIPopoverController alloc] initWithContentViewController:statusController];
		
		_popoverStatusController.popoverContentSize= CGSizeMake(STATUS_IPAD_WIDTH, STATUS_IPAD_HEIGHT);
		_popoverStatusController.delegate= self;
		
		[_popoverStatusController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	} else {
		StatusViewController *statusController= [[StatusViewController alloc] init];
		[self.navigationController pushViewController:statusController animated:YES];
	}
}


#pragma mark -
#pragma mark Methods of UIViewController

- (void) loadView {
	NSArray *niblets= [[NSBundle mainBundle] loadNibNamed:DEVICE_XIB(@"StockListView") owner:self options:NULL];
	_stockListView= (StockListView *) [niblets lastObject];
	
	self.tableView= _stockListView.table;
	self.view= _stockListView;
	
	_infoButton= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoTapped)];
    _infoButton.tintColor= [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem= _infoButton;
	
	_statusButton= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon_disconnected.png"] style:UIBarButtonItemStylePlain target:self action:@selector(statusTapped)];
    _statusButton.tintColor= [UIColor whiteColor];
	self.navigationItem.leftBarButtonItem= _statusButton;
	
	self.navigationController.delegate= self;
	
	if (DEVICE_IPAD) {
		
		// On the iPad we preselect the first row,
		// since the detail view is always visible
		_selectedRow= [NSIndexPath indexPathForRow:0 inSection:0];
		_detailController= [(AppDelegate_iPad *) [[UIApplication sharedApplication] delegate] detailController];
	}
	
	// We use the notification center to know when the
	// connection changes status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChanged) name:NOTIFICATION_CONN_STATUS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEnded) name:NOTIFICATION_CONN_ENDED object:nil];
	
    // Start connection in background
	dispatch_async(_backgroundQueue, ^() {
		[[Connector sharedConnector] connect];
	});
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (DEVICE_IPAD)
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	else
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate {
	return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
	if (DEVICE_IPAD)
		return UIInterfaceOrientationMaskLandscape;
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark -
#pragma mark Methods of UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return NUMBER_OF_ITEMS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Prepare the table cell
    StockListCell *cell= (StockListCell *) [tableView dequeueReusableCellWithIdentifier:@"StockListCell"];
    if (!cell) {
		NSArray *niblets= [[NSBundle mainBundle] loadNibNamed:DEVICE_XIB(@"StockListCell") owner:self options:NULL];
		cell= (StockListCell *) [niblets lastObject];
    }

	// Retrieve the item's data structures
	NSMutableDictionary *item= nil;
	NSMutableDictionary *itemUpdated= nil;
	@synchronized (_itemData) {
		item= [_itemData objectForKey:[NSNumber numberWithInteger:indexPath.row]];
		itemUpdated= [_itemUpdated objectForKey:[NSNumber numberWithInteger:indexPath.row]];
	}
	
	if (item) {
		
		// Update the cell appropriately
		NSString *colorName= [item objectForKey:@"color"];
		UIColor *color= nil;
		if ([colorName isEqualToString:@"green"])
			color= GREEN_COLOR;
		else if ([colorName isEqualToString:@"orange"])
			color= ORANGE_COLOR;
		else
			color= [UIColor whiteColor];
		
		cell.nameLabel.text= [item objectForKey:@"stock_name"];
		if ([[itemUpdated objectForKey:@"stock_name"] boolValue]) {
			if (!_stockListView.table.dragging)
				[SpecialEffects flashLabel:cell.nameLabel withColor:color];

			[itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"stock_name"];
		}
		
		cell.lastLabel.text= [item objectForKey:@"last_price"];
		if ([[itemUpdated objectForKey:@"last_price"] boolValue]) {
			if (!_stockListView.table.dragging)
				[SpecialEffects flashLabel:cell.lastLabel withColor:color];
			
			[itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"last_price"];
		}

		cell.timeLabel.text= [item objectForKey:@"time"];
		if ([[itemUpdated objectForKey:@"time"] boolValue]) {
			if (!_stockListView.table.dragging)
				[SpecialEffects flashLabel:cell.timeLabel withColor:color];
			
			[itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"time"];
		}

		double pctChange= [[item objectForKey:@"pct_change"] doubleValue];
		if (pctChange > 0.0)
			cell.dirImage.image= [UIImage imageNamed:@"Arrow-up.png"];
		else if (pctChange < 0.0)
			cell.dirImage.image= [UIImage imageNamed:@"Arrow-down.png"];
		else
			cell.dirImage.image= nil;

		cell.changeLabel.text= [NSString stringWithFormat:@"%@%%", [item objectForKey:@"pct_change"]];
		cell.changeLabel.textColor= (([[item objectForKey:@"pct_change"] doubleValue] >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR);

		if ([[itemUpdated objectForKey:@"pct_change"] boolValue]) {
			if (!_stockListView.table.dragging) {
				[SpecialEffects flashImage:cell.dirImage withColor:color];
				[SpecialEffects flashLabel:cell.changeLabel withColor:color];
			}
			
			[itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"pct_change"];
		}
	}
	
	// Update the cell text colors appropriately
	if ([indexPath isEqual:_selectedRow]) {
		cell.nameLabel.textColor= SELECTED_TEXT_COLOR;
		cell.lastLabel.textColor= SELECTED_TEXT_COLOR;
		cell.timeLabel.textColor= SELECTED_TEXT_COLOR;
	
	} else {
		cell.nameLabel.textColor= DEFAULT_TEXT_COLOR;
		cell.lastLabel.textColor= DEFAULT_TEXT_COLOR;
		cell.timeLabel.textColor= DEFAULT_TEXT_COLOR;
	}
    
    return cell;
}


#pragma mark -
#pragma mark Methods of UITableViewDelegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Mark the row to be reloaded
	@synchronized (_rowsToBeReloaded) {
		if (_selectedRow)
			[_rowsToBeReloaded addObject:_selectedRow];
		
		[_rowsToBeReloaded addObject:indexPath];
	}
	
	_selectedRow= indexPath;

	// Update the table view
	[self reloadTableRows];
	
	// On the iPhone the Detail View Controller is created on demand and pushed with
	// the navigation controller
	if (!_detailController) {
		_detailController= [[DetailViewController alloc] init];
		
		// Ensure the view is loaded
		[_detailController view];
	}

	// Update the item on the detail controller
	[_detailController changeItem:[TABLE_ITEMS objectAtIndex:indexPath.row]];
	
	if (!DEVICE_IPAD) {
		
		// On the iPhone the detail view controller may be already visible,
		// if it is not just push it
		if ([self.navigationController.viewControllers count] == 1)
			[self.navigationController pushViewController:_detailController animated:YES];
	}
	
	return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray *niblets= [[NSBundle mainBundle] loadNibNamed:DEVICE_XIB(@"StockListSection") owner:self options:NULL];

	return (UIView *) [niblets lastObject];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqual:_selectedRow])
		cell.backgroundColor= SELECTED_ROW_COLOR;
	else if (indexPath.row % 2 == 0)
		cell.backgroundColor= LIGHT_ROW_COLOR;
	else
		cell.backgroundColor= DARK_ROW_COLOR;
}


#pragma mark -
#pragma mark Methods of UIPopoverControllerDelegate

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	if (popoverController == _popoverInfoController) {
		_popoverInfoController= nil;
	
	} else if (popoverController == _popoverStatusController) {
		_popoverStatusController= nil;
	}
}


#pragma mark -
#pragma mark Methods of UINavigationControllerDelegate

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (!DEVICE_IPAD) {
		
		// Remove selection when coming back from detail view
		if (viewController == self) {
			
			// Mark the row to be reloaded
			@synchronized (_rowsToBeReloaded) {
				if (_selectedRow)
					[_rowsToBeReloaded addObject:_selectedRow];
			}
			
			_selectedRow= nil;
			
			// Update the table view
			[self reloadTableRows];
		}
	}
}


#pragma mark -
#pragma mark Lighstreamer connection status management

- (void) connectionStatusChanged {
	// This method is always called from a background thread

	// Check if we need to subscribe
	BOOL needsSubscription= ((!_subscribed) && [[[Connector sharedConnector] client] isConnected]);

	dispatch_async(dispatch_get_main_queue(), ^{
		
		// Update connection status icon
		switch ([[[Connector sharedConnector] client] connectionStatus]) {
			case LSConnectionStatusDisconnected:
				self.navigationItem.leftBarButtonItem.image= [UIImage imageNamed:@"Icon_disconnected.png"];
				break;
				
			case LSConnectionStatusConnecting:
				self.navigationItem.leftBarButtonItem.image= [UIImage imageNamed:@"Icon_connecting.png"];
				break;

			case LSConnectionStatusStalled:
				self.navigationItem.leftBarButtonItem.image= [UIImage imageNamed:@"Icon_stalled.png"];
				break;
				
			case LSConnectionStatusConnectedInPollingMode:
				self.navigationItem.leftBarButtonItem.image= [UIImage imageNamed:@"Icon_polling.png"];
				break;
				
			case LSConnectionStatusConnectedInStreamingMode:
				self.navigationItem.leftBarButtonItem.image= [UIImage imageNamed:@"Icon_streaming.png"];
				break;
		}
		
		// If the detail controller is visible, set the item on the detail view controller,
		// so that it can do its own subscription
		if (needsSubscription && (DEVICE_IPAD || ([self.navigationController.viewControllers count] > 1)))
			[_detailController changeItem:[TABLE_ITEMS objectAtIndex:_selectedRow.row]];
	});
	
	// Check if we need to subscribe
	if (needsSubscription) {
		_subscribed= YES;

		// Subscribe the table on a background thread
		dispatch_async(_backgroundQueue, ^() {
			NSLog(@"StockListViewController: subscribing table...");
			
			@try {
				
				// The LSClient will reconnect and resubscribe automatically
				LSExtendedTableInfo *tableInfo= [LSExtendedTableInfo extendedTableInfoWithItems:TABLE_ITEMS
																						   mode:LSModeMerge
																						 fields:LIST_FIELDS
																					dataAdapter:DATA_ADAPTER
																					   snapshot:YES];
				
				_tableKey= [[[Connector sharedConnector] client] subscribeTableWithExtendedInfo:tableInfo
																					   delegate:self
																				useCommandLogic:NO];
				
				NSLog(@"StockListViewController: table subscribed");
				
			} @catch (NSException *e) {
				NSLog(@"StockListViewController: table subscription failed with to exception: %@", e);
			}
		});
	}
}

- (void) connectionEnded {
	// This method is always called from a background thread
	
	// Connection was forcibly closed by the server,
	// prepare for a new subscription
	_subscribed= NO;
	_tableKey= nil;
	
    // Start a new connection in background
	dispatch_async(_backgroundQueue, ^() {
		[[Connector sharedConnector] connect];
	});
}


#pragma mark -
#pragma mark Internals

- (void) reloadTableRows {
	// This method is always called from the main thread

	NSMutableArray *rowsToBeReloaded= nil;
	@synchronized (_rowsToBeReloaded) {
		rowsToBeReloaded= [[NSMutableArray alloc] initWithCapacity:[_rowsToBeReloaded count]];
		
		for (NSIndexPath *indexPath in _rowsToBeReloaded)
			[rowsToBeReloaded addObject:indexPath];

		[_rowsToBeReloaded removeAllObjects];
	}
	
	// Ask the table to reload the marked rows
	[_stockListView.table reloadRowsAtIndexPaths:rowsToBeReloaded withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark Methods of LSTableDelegate

- (void) table:(LSSubscribedTableKey *)tableKey itemPosition:(int)itemPosition itemName:(NSString *)itemName didUpdateWithInfo:(LSUpdateInfo *)updateInfo {
	// This method is always called from a background thread
	
	// Check and prepare the item's data structures
	NSMutableDictionary *item= nil;
	NSMutableDictionary *itemUpdated= nil;
	@synchronized (_itemData) {
		item= [_itemData objectForKey:[NSNumber numberWithInt:(itemPosition -1)]];
		if (!item) {
			item= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_LIST_FIELDS];
			[_itemData setObject:item forKey:[NSNumber numberWithInt:(itemPosition -1)]];
		}

		itemUpdated= [_itemUpdated objectForKey:[NSNumber numberWithInt:(itemPosition -1)]];
		if (!itemUpdated) {
			itemUpdated= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_LIST_FIELDS];
			[_itemUpdated setObject:itemUpdated forKey:[NSNumber numberWithInt:(itemPosition -1)]];
		}
	}
		
	// Store the updated fields in the item's data structures
	for (NSString *fieldName in LIST_FIELDS) {
		NSString *value= [updateInfo currentValueOfFieldName:fieldName];
		
		if (value)
			[item setObject:value forKey:fieldName];
		else
			[item setObject:[NSNull null] forKey:fieldName];
		
		if ([updateInfo isChangedValueOfFieldName:fieldName])
			[itemUpdated setObject:[NSNumber numberWithBool:YES] forKey:fieldName];
	}
	
	// Evaluate the update color and store it in the item's data structures
	double currentLastPrice= [[updateInfo currentValueOfFieldName:@"last_price"] doubleValue];
	double previousLastPrice= [[updateInfo previousValueOfFieldName:@"last_price"] doubleValue];
	if (currentLastPrice >= previousLastPrice)
		[item setObject:@"green" forKey:@"color"];
	else
		[item setObject:@"orange" forKey:@"color"];
	
	// Mark rows to be reload
	@synchronized (_rowsToBeReloaded) {
		[_rowsToBeReloaded addObject:[NSIndexPath indexPathForRow:(itemPosition -1) inSection:0]];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		// Update the table view
		[self reloadTableRows];
	});
}


@end

