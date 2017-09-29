//
//  MarqueeView.h
//  EZAudioRecordExample
//
//  Created by Francois Reboursier on 28/09/2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import "ZLHistogramAudioPlot.h"

@interface MarqueeView : UIView

@property   (weak)  IBOutlet        UIImageView     *imageView;
@property (nonatomic, weak) IBOutlet ZLHistogramAudioPlot *audioPlot;

@end
