//
//  DetailView.h
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

#import <UIKit/UIKit.h>


@interface DetailView : UIView {
	IBOutlet __weak UILabel *_nameLabel;
	IBOutlet __weak UILabel *_lastLabel;
	IBOutlet __weak UILabel *_timeLabel;
	IBOutlet __weak UIImageView *_dirImage;
	IBOutlet __weak UILabel *_changeLabel;
	IBOutlet __weak UILabel *_openLabel;
	IBOutlet __weak UILabel *_bidLabel;
	IBOutlet __weak UILabel *_askLabel;
	IBOutlet __weak UILabel *_bidSizeLabel;
	IBOutlet __weak UILabel *_askSizeLabel;
	IBOutlet __weak UILabel *_minLabel;
	IBOutlet __weak UILabel *_maxLabel;
	IBOutlet __weak UILabel *_refLabel;
	IBOutlet __weak UIView *_chartBackgroundView;
	IBOutlet __weak UILabel *_chartTipLabel;
	IBOutlet __weak UILabel *_switchTipLabel;
}


#pragma mark -
#pragma mark Properties

@property (weak, nonatomic, readonly) UILabel *nameLabel;
@property (weak, nonatomic, readonly) UILabel *lastLabel;
@property (weak, nonatomic, readonly) UILabel *timeLabel;
@property (weak, nonatomic, readonly) UIImageView *dirImage;
@property (weak, nonatomic, readonly) UILabel *changeLabel;
@property (weak, nonatomic, readonly) UILabel *openLabel;
@property (weak, nonatomic, readonly) UILabel *bidLabel;
@property (weak, nonatomic, readonly) UILabel *askLabel;
@property (weak, nonatomic, readonly) UILabel *bidSizeLabel;
@property (weak, nonatomic, readonly) UILabel *askSizeLabel;
@property (weak, nonatomic, readonly) UILabel *minLabel;
@property (weak, nonatomic, readonly) UILabel *maxLabel;
@property (weak, nonatomic, readonly) UILabel *refLabel;
@property (weak, nonatomic, readonly) UILabel *chartTipLabel;
@property (weak, nonatomic, readonly) UILabel *switchTipLabel;
@property (weak, nonatomic, readonly) UIView *chartBackgroundView;


@end
