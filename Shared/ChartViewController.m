//
//  ChartViewController.m
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

#import "ChartViewController.h"
#import "ChartView.h"

#define SERVER_TIMEZONE                     (@"Europe/Dublin")

#define TAP_SENSIBILITY_PIXELS              (20.0)


@implementation ChartViewController


#pragma mark -
#pragma mark Initialization

- (id) init {
    self = [super init];
    if (self) {
		
		// Prepare reference date
		NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

		NSDateComponents *comps= [[NSDateComponents alloc] init];
		[comps setDay:19];
		[comps setMonth:2];
		[comps setYear:2014];
		_referenceDate= [calendar dateFromComponents:comps];
		
		// Prepare time parser
		_timeFormatter= [[NSDateFormatter alloc] init];
		[_timeFormatter setDateFormat:@"HH:mm:ss"];
    }
	
    return self;
}


#pragma mark -
#pragma mark Methods of UIViewController

- (void) loadView {
	_chartView= [[ChartView alloc] initWithFrame:CGRectZero];
	
	self.view= _chartView;
}


#pragma mark -
#pragma mark Chart management

- (void) clearChart {
	[self clearChartWithMin:0.0 max:0.0 time:[[NSDate date] timeIntervalSinceDate:_referenceDate] value:0.0];
}

- (void) clearChartWithMin:(float)min max:(float)max time:(NSTimeInterval)time value:(float)value {
	[_chartView clearValues];
	
	_chartView.min= min;
	_chartView.max= max;
	_chartView.end= time;
	_chartView.begin= time - 120.0;
	
	if (value != 0.0)
		[_chartView addValue:value withTime:time];
}


#pragma mark -
#pragma mark Updates from Lightstreamer

- (void) itemDidUpdateWithInfo:(LSItemUpdate *)itemUpdate {
	
	// Extract last point time
	NSString *timeString= [itemUpdate valueWithFieldName:@"time"];
	NSDate *updateTime= [_timeFormatter dateFromString:timeString];
	
	// Compute the full date knowing the Server lives in the West European time zone
	// (which is not simply GMT, as it may undergo daylight savings)
	NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSTimeZone *timeZone= [NSTimeZone timeZoneWithName:SERVER_TIMEZONE];
	[calendar setTimeZone:timeZone];
	
	NSDateComponents *nowComponents= [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
	NSDateComponents *timeComponents=[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:updateTime];
	
	NSDateComponents *dateComponents= [[NSDateComponents alloc] init];
	[dateComponents setTimeZone:timeZone]; // The timezone is known a-priori
	[dateComponents setYear:nowComponents.year]; // Take the current day
	[dateComponents setMonth:nowComponents.month];
	[dateComponents setDay:nowComponents.day];
	[dateComponents setHour:timeComponents.hour]; // Take the time of the update
	[dateComponents setMinute:timeComponents.minute];
	[dateComponents setSecond:timeComponents.second];
	
	NSDate *updateDate= [calendar dateFromComponents:dateComponents];
	NSTimeInterval time= [updateDate timeIntervalSinceDate:_referenceDate];
	
	// Extract last point data
	float value= [[itemUpdate valueWithFieldName:@"last_price"] floatValue];
	float min= [[itemUpdate valueWithFieldName:@"min"] floatValue];
	float max= [[itemUpdate valueWithFieldName:@"max"] floatValue];
	
	// Update chart
	_chartView.min= min;
	_chartView.max= max;
	_chartView.end= time;
	_chartView.begin= time - 120.0;

	[_chartView addValue:value withTime:time];
}


@end
