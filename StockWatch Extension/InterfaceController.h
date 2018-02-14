//
//  InterfaceController.h
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

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>


@interface InterfaceController : WKInterfaceController <LSSubscriptionDelegate>


#pragma mark -
#pragma mark Stock selection

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *stockPicker;

- (IBAction) stockSelected:(NSInteger)value;


#pragma mark -
#pragma mark Data visualization

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *priceGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lastLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *changeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *dirImage;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *openLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;


@end

