//
//  SpecialEffects.m
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

#import "SpecialEffects.h"
#import "Constants.h"


@implementation SpecialEffects


#pragma mark -
#pragma mark UI element flashing

+ (void) flashLabel:(UILabel *)label withColor:(UIColor *)color {
	label.layer.backgroundColor= color.CGColor;
	if (label.tag == COLORED_LABEL_TAG)
		label.textColor= [UIColor blackColor];
	
	[[SpecialEffects class] performSelector:@selector(unflashLabel:) withObject:label afterDelay:FLASH_DURATION];
}


+ (void) flashImage:(UIImageView *)imageView withColor:(UIColor *)color {
	imageView.backgroundColor= color;
	
	[[SpecialEffects class] performSelector:@selector(unflashImage:) withObject:imageView afterDelay:FLASH_DURATION];
}


#pragma mark -
#pragma mark Internals

+ (void) unflashLabel:(UILabel *)label {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:FLASH_DURATION];
	
	label.layer.backgroundColor= [UIColor clearColor].CGColor;
	if (label.tag == COLORED_LABEL_TAG)
		label.textColor= (([label.text doubleValue] >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR);
	
	[UIView commitAnimations];
}

+ (void) unflashImage:(UIImageView *)imageView {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:FLASH_DURATION];
	
	imageView.backgroundColor= [UIColor clearColor];
	
	[UIView commitAnimations];
}


@end
