//
//  ChartView.m
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

#import "ChartView.h"

#import <CoreText/CoreText.h>

#define LEFT_AXIS_MARGIN            (40.0)
#define BOTTOM_AXIS_MARGIN          (20.0)
#define RIGHT_MARGIN                (40.0)

#define CHART_BACKGROUND_COLOR      ([UIColor colorWithRed:0.7176 green:0.8431 blue:0.9647 alpha:1.0000])
#define AXIS_LINE_COLOR             ([UIColor darkGrayColor])
#define AXIS_LABEL_COLOR            ([UIColor darkGrayColor])
#define INTEGER_LINE_COLOR          ([UIColor darkGrayColor])
#define INTEGER_LABEL_COLOR         ([UIColor darkGrayColor])
#define VALUE_LINE_COLOR            ([UIColor blueColor])
#define VALUE_LABEL_COLOR           ([UIColor blueColor])

#define AXIS_LINE_WIDTH              (2.0)
#define INTEGER_LINE_WIDTH           (1.0)
#define VALUE_LINE_WIDTH             (2.0)

#define FONT_SIZE                   (11.0)


@implementation ChartView


#pragma mark -
#pragma mark Initialization

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        // Initialization
		_data= [[NSMutableArray alloc] init];
		
		self.clearsContextBeforeDrawing= YES;
		self.clipsToBounds= YES;
    }
	
    return self;
}


#pragma mark -
#pragma mark Data management

- (void) addValue:(float)value withTime:(NSTimeInterval)time {
	@synchronized (self) {
	
		// Add value, keeping the array sorted
		NSValue *point= [NSValue valueWithCGPoint:CGPointMake(time, value)];

		NSUInteger index= [_data indexOfObject:point
								 inSortedRange:NSMakeRange(0, [_data count])
									   options:NSBinarySearchingLastEqual | NSBinarySearchingInsertionIndex
							   usingComparator:^NSComparisonResult(id obj1, id obj2) {
								   CGPoint point1= [(NSValue *) obj1 CGPointValue];
								   CGPoint point2= [(NSValue *) obj2 CGPointValue];
							
								   if (point1.x < point2.x)
									   return NSOrderedAscending;
								   else if (point1.x > point2.x)
									   return NSOrderedDescending;
								   else
									   return NSOrderedSame;
							   }];
		
		[_data insertObject:[NSValue valueWithCGPoint:CGPointMake(time, value)] atIndex:index];
		
		// Strip out values out of time range
		NSValue *begin= [NSValue valueWithCGPoint:CGPointMake(_begin, 0.0)];
		
		index= [_data indexOfObject:begin
					  inSortedRange:NSMakeRange(0, [_data count])
							options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
					usingComparator:^NSComparisonResult(id obj1, id obj2) {
						CGPoint point1= [(NSValue *) obj1 CGPointValue];
						CGPoint point2= [(NSValue *) obj2 CGPointValue];
						
						if (point1.x < point2.x)
							return NSOrderedAscending;
						else if (point1.x > point2.x)
							return NSOrderedDescending;
						else
							return NSOrderedSame;
					}];
		
		if (index >= 1)
			[_data removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)]];
		
		NSValue *end= [NSValue valueWithCGPoint:CGPointMake(_end, 0.0)];
		
		index= [_data indexOfObject:end
					  inSortedRange:NSMakeRange(0, [_data count])
							options:NSBinarySearchingLastEqual | NSBinarySearchingInsertionIndex
					usingComparator:^NSComparisonResult(id obj1, id obj2) {
						CGPoint point1= [(NSValue *) obj1 CGPointValue];
						CGPoint point2= [(NSValue *) obj2 CGPointValue];
						
						if (point1.x < point2.x)
							return NSOrderedAscending;
						else if (point1.x > point2.x)
							return NSOrderedDescending;
						else
							return NSOrderedSame;
					}];
		
		if (index < [_data count])
			[_data removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [_data count] -index)]];
	}
	
	[self setNeedsDisplay];
}

- (void) clearValues {
	@synchronized (self) {
		[_data removeAllObjects];
	}
	
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Coordinates managements

- (CGPoint) valueAtPoint:(CGPoint)point {
	float x= point.x;
	float y= point.y;
	
	CGSize size= self.frame.size;
	
	float propX= (x - LEFT_AXIS_MARGIN) / (size.width - LEFT_AXIS_MARGIN - RIGHT_MARGIN);
	float propY= (size.height - BOTTOM_AXIS_MARGIN - y) / (size.height - BOTTOM_AXIS_MARGIN);
	
	float time= _begin + propX * (_end - _begin);
	float value= _min + propY * (_max - _min);

	return CGPointMake(time, value);
}

- (CGPoint) pointForValue:(CGPoint)point {
	NSTimeInterval time= point.x;
	float value= point.y;
	
	float deltaX= time - _begin;
	float deltaY= value - _min;
	
	float propX= deltaX / (_end - _begin);
	float propY= deltaY / (_max - _min);
	
	CGSize size= self.frame.size;
	
	float x= LEFT_AXIS_MARGIN + ((size.width - LEFT_AXIS_MARGIN - RIGHT_MARGIN) * propX);
	float y= (size.height - BOTTOM_AXIS_MARGIN) - ((size.height - BOTTOM_AXIS_MARGIN) * propY);
	
	if (x < LEFT_AXIS_MARGIN)
		x= LEFT_AXIS_MARGIN;
	
	if (x >= size.width)
		x= size.width;
	
	if (y < 0.0)
		y= 0.0;
	
	if (y >= (size.height - BOTTOM_AXIS_MARGIN))
		y= (size.height - BOTTOM_AXIS_MARGIN);
	
	return CGPointMake(x, y);
}


#pragma mark -
#pragma mark Properties

@dynamic min;

- (float) min {
	return _min;
}

- (void) setMin:(float)min {
	@synchronized (self) {
		_min= min;
	}
	
	[self setNeedsDisplay];
}

@dynamic max;

- (float) max {
	return _max;
}

- (void) setMax:(float)max {
	@synchronized (self) {
		_max= max;
	}
	
	[self setNeedsDisplay];
}

@dynamic begin;

- (NSTimeInterval) begin {
	return _begin;
}

- (void) setBegin:(NSTimeInterval)begin {
	@synchronized (self) {
		_begin= begin;
	}
	
	[self setNeedsDisplay];
}

@dynamic end;

- (NSTimeInterval) end {
	return _end;
}

- (void) setEnd:(NSTimeInterval)end {
	@synchronized (self) {
		_end= end;
	}
	
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Drawing

- (void) drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGSize size= self.frame.size;
	CGContextRef context= UIGraphicsGetCurrentContext();
	
	CTFontRef sysFont= CTFontCreateUIFontForLanguage(kCTFontSystemFontType, FONT_SIZE, NULL);
	CTFontRef sysBoldFont= CTFontCreateUIFontForLanguage(kCTFontUIFontEmphasizedSystem, FONT_SIZE, NULL);
	
	CGAffineTransform transform= CGAffineTransformMakeTranslation(0.0, size.height);
	CGAffineTransform transform2= CGAffineTransformScale(transform, 1.0, -1.0);
	CGContextSetTextMatrix(context, transform2);
	
	@synchronized (self) {
		
		// Draw the chart background
		CGContextSetFillColorWithColor(context, CHART_BACKGROUND_COLOR.CGColor);
		CGContextFillRect(context, CGRectMake(LEFT_AXIS_MARGIN, 0.0, size.width - LEFT_AXIS_MARGIN, size.height - BOTTOM_AXIS_MARGIN));

		// Draw the two axis
		CGContextSetStrokeColorWithColor(context, AXIS_LINE_COLOR.CGColor);
		CGContextSetLineWidth(context, AXIS_LINE_WIDTH);

		CGContextMoveToPoint(context, LEFT_AXIS_MARGIN, 0.0);
		CGContextAddLineToPoint(context, LEFT_AXIS_MARGIN, size.height);
		CGContextStrokePath(context);

		CGContextMoveToPoint(context, 0.0, size.height - BOTTOM_AXIS_MARGIN);
		CGContextAddLineToPoint(context, size.width, size.height - BOTTOM_AXIS_MARGIN);
		CGContextStrokePath(context);
		
		// Draw integer lines
		CGContextSetStrokeColorWithColor(context, INTEGER_LINE_COLOR.CGColor);
		CGContextSetLineWidth(context, INTEGER_LINE_WIDTH);
		CTLineRef line= nil;
		
		NSDictionary *attributesDict= [NSDictionary dictionaryWithObjectsAndKeys:
									   (__bridge id) sysFont, (id) kCTFontAttributeName,
									   INTEGER_LABEL_COLOR.CGColor, (id) kCTForegroundColorAttributeName,
									   nil];
		
		float dashPhase= 0.0;
		float dashLengths[] = { 10.0, 5.0 };
		CGContextSetLineDash(context, dashPhase, (const CGFloat *) dashLengths, 2);
		
		int current= ((int) (_min + 1.0));
		while (current < _max) {
			
			// Compute position
			CGPoint point= [self pointForValue:CGPointMake(0.0, current)];
			float y= point.y;
			
			CGContextMoveToPoint(context, LEFT_AXIS_MARGIN, y);
			CGContextAddLineToPoint(context, size.width, y);
			CGContextStrokePath(context);
			
			// Draw label
			if ((y > FONT_SIZE + 5.0) && (y < (size.height - BOTTOM_AXIS_MARGIN - FONT_SIZE - 5.0))) {
				NSString *intLabel= [NSString stringWithFormat:@"%7.2f", ((float) current)];
				NSAttributedString *intLabelAttr= [[NSAttributedString alloc] initWithString:intLabel attributes:attributesDict];
				CGContextSetTextPosition(context, 0.0, y);
				
				CTLineRef line= CTLineCreateWithAttributedString((CFAttributedStringRef) intLabelAttr);
				CTLineDraw(line, context);
				CFRelease(line);
			}
			
			current++;
		}
		
		// Draw the Y axis labels
		attributesDict= [NSDictionary dictionaryWithObjectsAndKeys:
						 (__bridge id) sysBoldFont, (id) kCTFontAttributeName,
						 AXIS_LABEL_COLOR.CGColor, (id) kCTForegroundColorAttributeName,
						 nil];
		
		float maxY= FONT_SIZE;
		NSString *maxLabel= [NSString stringWithFormat:@"%7.2f", _max];
		NSAttributedString *maxLabelAttr= [[NSAttributedString alloc] initWithString:maxLabel attributes:attributesDict];
		CGContextSetTextPosition(context, 0.0, maxY);
		line= CTLineCreateWithAttributedString((CFAttributedStringRef) maxLabelAttr);
		CTLineDraw(line, context);
		CFRelease(line);
		
		float minY= size.height - BOTTOM_AXIS_MARGIN - 5.0;
		NSString *minLabel= [NSString stringWithFormat:@"%7.2f", _min];
		NSAttributedString *minLabelAttr= [[NSAttributedString alloc] initWithString:minLabel attributes:attributesDict];
		CGContextSetTextPosition(context, 0.0, minY);
		line= CTLineCreateWithAttributedString((CFAttributedStringRef) minLabelAttr);
		CTLineDraw(line, context);
		CFRelease(line);
		
		// Draw the X axis labels
		NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"HH:mm:ss"];
		
		NSString *beginLabel= [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_begin]];
		NSAttributedString *beginLabelAttr= [[NSAttributedString alloc] initWithString:beginLabel attributes:attributesDict];
		CGContextSetTextPosition(context, LEFT_AXIS_MARGIN + 5.0, size.height - 5.0);
		line= CTLineCreateWithAttributedString((CFAttributedStringRef) beginLabelAttr);
		CTLineDraw(line, context);
		CFRelease(line);
		
		NSString *middleLabel= [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:(_begin + _end) / 2.0]];
		NSAttributedString *middleLabelAttr= [[NSAttributedString alloc] initWithString:middleLabel attributes:attributesDict];
		CGContextSetTextPosition(context, LEFT_AXIS_MARGIN + ((size.width - LEFT_AXIS_MARGIN) / 2.0) - (FONT_SIZE * 2.0), size.height - 5.0);
		line= CTLineCreateWithAttributedString((CFAttributedStringRef) middleLabelAttr);
		CTLineDraw(line, context);
		CFRelease(line);
		
		NSString *endLabel= [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_end]];
		NSAttributedString *endLabelAttr= [[NSAttributedString alloc] initWithString:endLabel attributes:attributesDict];
		CGContextSetTextPosition(context, size.width - (FONT_SIZE * 4.0), size.height - 5.0);
		line= CTLineCreateWithAttributedString((CFAttributedStringRef) endLabelAttr);
		CTLineDraw(line, context);
		CFRelease(line);
		
		// Draw data
		CGContextSetStrokeColorWithColor(context, VALUE_LINE_COLOR.CGColor);
		CGContextSetLineWidth(context, VALUE_LINE_WIDTH);
		CGContextSetLineDash(context, 0.0, NULL, 0);

		float lastValue= 0.0;
		float lastY= 0.0;
		BOOL first= YES;

		for (NSValue *pointValue in _data) {
			CGPoint point= [self pointForValue:[pointValue CGPointValue]];
			float x= point.x;
			float y= point.y;
			
			lastValue= [pointValue CGPointValue].y;
			lastY= y;
			
			if (first) {
				CGContextMoveToPoint(context, x, y);
				first= NO;

				// Draw at least a dot if there's just one point
				if ([_data count] == 1)
					CGContextAddLineToPoint(context, x + VALUE_LINE_WIDTH, y);
			
			} else
				CGContextAddLineToPoint(context, x, y);
		}
		
		if (!first) {
			
			// Draw line and label if there's at least one point
			CGContextStrokePath(context);
		
			// Draw last point label
			attributesDict= [NSDictionary dictionaryWithObjectsAndKeys:
							 (__bridge id) sysBoldFont, (id) kCTFontAttributeName,
							 VALUE_LABEL_COLOR.CGColor, (id) kCTForegroundColorAttributeName,
							 nil];
			
			NSString *label= [NSString stringWithFormat:@"%7.2f", lastValue];
			NSAttributedString *labelAttr= [[NSAttributedString alloc] initWithString:label attributes:attributesDict];
			CGContextSetTextPosition(context, size.width - RIGHT_MARGIN, lastY);
			line= CTLineCreateWithAttributedString((CFAttributedStringRef) labelAttr);
			CTLineDraw(line, context);
			CFRelease(line);
		}
	}
	
	// Cleanup
	CFRelease(sysFont);
	CFRelease(sysBoldFont);
}


@end
