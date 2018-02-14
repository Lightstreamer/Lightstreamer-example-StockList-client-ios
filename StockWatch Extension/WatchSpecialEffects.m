//
//  WatchSpecialEffects.m
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

#import "WatchSpecialEffects.h"
#import "Constants.h"


@implementation WatchSpecialEffects


#pragma mark -
#pragma mark UI element flashing

+ (void) flashGroup:(WKInterfaceGroup *)group withColor:(UIColor *)color {
    group.backgroundColor= color;
    
    [[WatchSpecialEffects class] performSelector:@selector(unflashGrup:) withObject:group afterDelay:FLASH_DURATION];
}


#pragma mark -
#pragma mark Internals

+ (void) unflashGrup:(WKInterfaceGroup *)group {
    group.backgroundColor= [UIColor clearColor];
}


@end

