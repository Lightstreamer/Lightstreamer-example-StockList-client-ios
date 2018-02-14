//
//  InterfaceController.m
//  StockWatch Extension
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

#import "InterfaceController.h"
#import "WatchSpecialEffects.h"
#import "Connector.h"
#import "Constants.h"


#pragma mark -
#pragma mark InterfaceController extension

@interface InterfaceController () {
    BOOL _subscribed;
    LSSubscription *_subscription;
    
    NSInteger _selectedItem;
    NSMutableDictionary *_itemUpdated;
    NSMutableDictionary *_itemData;
}


#pragma mark -
#pragma mark Lightstreamer connection status management

- (void) connectionStatusChanged;
- (void) connectionEnded;


#pragma mark -
#pragma mark Internals

- (void) updatePicker;
- (void) updateData;


@end


#pragma mark -
#pragma mark InterfaceController implementation

@implementation InterfaceController


#pragma mark -
#pragma mark Life cycle

- (void) awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Multiple-item data structures: each item has a second-level dictionary.
    // They store fields data and which fields have been updated
    _itemData= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_ITEMS];
    _itemUpdated= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_ITEMS];
    
    // We use the notification center to know when the
    // connection changes status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChanged) name:NOTIFICATION_CONN_STATUS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEnded) name:NOTIFICATION_CONN_ENDED object:nil];
    
    // Fill the picker
    [self updatePicker];
    
    // Start connection (executes in background)
    [[Connector sharedConnector] connect];
}

- (void) willActivate {
    [super willActivate];
    
    // Nothing to do, for now
}

- (void) didDeactivate {
    [super didDeactivate];
    
    // Nothing to do, for now
}


#pragma mark -
#pragma mark Stock selection

- (IBAction) stockSelected:(NSInteger)value {
    _selectedItem= value;
    
    // Update the view
    [self updateData];
}


#pragma mark -
#pragma mark Lighstreamer connection status management

- (void) connectionStatusChanged {
    // This method is always called from a background thread
    
    // Check if we need to subscribe
    BOOL needsSubscription= ((!_subscribed) && [[Connector sharedConnector] isConnected]);
    if (needsSubscription) {
        _subscribed= YES;
        
        NSLog(@"InterfaceController: subscribing table...");
        
        // The LSLightstreamerClient will reconnect and resubscribe automatically
        _subscription= [[LSSubscription alloc] initWithSubscriptionMode:@"MERGE" items:TABLE_ITEMS fields:DETAIL_FIELDS];
        _subscription.dataAdapter= DATA_ADAPTER;
        _subscription.requestedSnapshot= @"yes";
        [_subscription addDelegate:self];
        
        [[Connector sharedConnector] subscribe:_subscription];
    }
}

- (void) connectionEnded {
    // This method is always called from a background thread
    
    // Connection was forcibly closed by the server,
    // prepare for a new subscription
    _subscribed= NO;
    _subscription= nil;
    
    // Start a new connection (executes in background)
    [[Connector sharedConnector] connect];
}


#pragma mark -
#pragma mark Methods of LSSubscriptionDelegate

- (void) subscription:(nonnull LSSubscription *)subscription didUpdateItem:(nonnull LSItemUpdate *)itemUpdate {
    // This method is always called from a background thread
    
    NSUInteger itemPosition= itemUpdate.itemPos;
    BOOL updatePicker= NO;
    
    // Check and prepare the item's data structures
    NSMutableDictionary *item= nil;
    NSMutableDictionary *itemUpdated= nil;
    @synchronized (_itemData) {
        item= [_itemData objectForKey:[NSNumber numberWithUnsignedInteger:(itemPosition -1)]];
        if (!item) {
            item= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_DETAIL_FIELDS];
            [_itemData setObject:item forKey:[NSNumber numberWithUnsignedInteger:(itemPosition -1)]];
        }
        
        itemUpdated= [_itemUpdated objectForKey:[NSNumber numberWithUnsignedInteger:(itemPosition -1)]];
        if (!itemUpdated) {
            itemUpdated= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_DETAIL_FIELDS];
            [_itemUpdated setObject:itemUpdated forKey:[NSNumber numberWithUnsignedInteger:(itemPosition -1)]];
        }
    }
    
    double previousLastPrice= 0.0;
    for (NSString *fieldName in DETAIL_FIELDS) {
        
        // Save previous last price to choose blink color later
        if ([fieldName isEqualToString:@"last_price"])
            previousLastPrice= [[item objectForKey:fieldName] doubleValue];
        
        // Store the updated field in the item's data structures
        NSString *value= [itemUpdate valueWithFieldName:fieldName];
        
        if (value)
            [item setObject:value forKey:fieldName];
        else
            [item setObject:[NSNull null] forKey:fieldName];
        
        if ([itemUpdate isValueChangedWithFieldName:fieldName]) {
            [itemUpdated setObject:[NSNumber numberWithBool:YES] forKey:fieldName];
            
            // If the stock name changed we also have to reload the picker
            if ([fieldName isEqualToString:@"stock_name"])
                updatePicker= YES;
        }
    }
    
    // Evaluate the update color and store it in the item's data structures
    double currentLastPrice= [[itemUpdate valueWithFieldName:@"last_price"] doubleValue];
    if (currentLastPrice >= previousLastPrice)
        [item setObject:@"green" forKey:@"color"];
    else
        [item setObject:@"orange" forKey:@"color"];
    
    BOOL updateData= (_selectedItem == (itemPosition -1));
    if (updateData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Update the view
            [self updateData];
        });
    }
    
    if (updatePicker) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Update the picker
            [self updatePicker];
        });
    }
}

#pragma mark -
#pragma mark Internals

- (void) updatePicker {
    // This method is always called from the main thread
    
    NSMutableArray *pickerItems= [NSMutableArray array];
    
    @synchronized (_itemData) {
        for (NSUInteger i= 0; i < NUMBER_OF_ITEMS; i++) {
            NSDictionary *item= [_itemData objectForKey:[NSNumber numberWithUnsignedInteger:i]];
            NSString *stockName= [item objectForKey:@"stock_name"];
            
            WKPickerItem *pickerItem= [[WKPickerItem alloc] init];
            pickerItem.title= stockName ? stockName : [NSString stringWithFormat:@"Loading item%u...", i +1];
            [pickerItems addObject:pickerItem];
        }
    }
    
    [self.stockPicker setItems:pickerItems];
}

- (void) updateData {
    // This method is always called from the main thread
    
    // Retrieve the item's data structures
    NSMutableDictionary *item= nil;
    NSMutableDictionary *itemUpdated= nil;
    @synchronized (_itemData) {
        item= [_itemData objectForKey:[NSNumber numberWithInteger:_selectedItem]];
        itemUpdated= [_itemUpdated objectForKey:[NSNumber numberWithInteger:_selectedItem]];
    }
    
    if (item) {
        
        // Update the labels
        self.lastLabel.text= [item objectForKey:@"last_price"];
        if ([[itemUpdated objectForKey:@"last_price"] boolValue]) {
            
            // Flash the price-dir-change group appropriately
            NSString *colorName= [item objectForKey:@"color"];
            UIColor *color= nil;
            if ([colorName isEqualToString:@"green"])
                color= GREEN_COLOR;
            else if ([colorName isEqualToString:@"orange"])
                color= ORANGE_COLOR;
            else
                color= [UIColor whiteColor];
            
            [WatchSpecialEffects flashGroup:self.priceGroup withColor:color];
            
            [itemUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"last_price"];
        }
        
        self.timeLabel.text= [item objectForKey:@"time"];
        self.openLabel.text= [item objectForKey:@"open_price"];
        
        double pctChange= [[item objectForKey:@"pct_change"] doubleValue];
        if (pctChange > 0.0)
            self.dirImage.image= [UIImage imageNamed:@"Arrow-up"];
        else if (pctChange < 0.0)
            self.dirImage.image= [UIImage imageNamed:@"Arrow-down"];
        else
            self.dirImage.image= nil;
        
        self.changeLabel.text= [NSString stringWithFormat:@"%@%%", [item objectForKey:@"pct_change"]];
        self.changeLabel.textColor= (([[item objectForKey:@"pct_change"] doubleValue] >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR);
    }
}


@end

