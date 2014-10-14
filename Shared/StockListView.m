//
//  StockListView.m
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

#import "StockListView.h"


@implementation StockListView


#pragma mark -
#pragma mark Initialization

- (id) initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		
        // Nothing to do, actually
    }

    return self;
}


#pragma mark -
#pragma mark Properties

@synthesize table= _table;


@end
