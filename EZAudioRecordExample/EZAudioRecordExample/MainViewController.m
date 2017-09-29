//
//  MainViewController.m
//  EZAudioRecordExample
//
//  Created by Francois Reboursier on 28/09/2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import "MainViewController.h"
#import "MarqueeView.h"
#import "EZAudio.h"


@interface MainViewController ()
@property   (retain)    UIWindow    *externalWindow;
@property   (weak)  MarqueeView  *marqueeView;

@property (nonatomic, strong) EZMicrophone *microphone;

@end

@implementation MainViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
    
   
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[UIScreen screens] count] > 1)
    {
        [self initializeExternalScreen:[[UIScreen screens] objectAtIndex:1]];
    }
}

- (void)handleScreenDidConnect:(NSNotification *)notification
{
    [self initializeExternalScreen:notification.object];
}


- (void)handleScreenDidDisconnect:(NSNotification *)notification
{
    if (self.externalWindow)
    {
        self.externalWindow.hidden = TRUE;
        self.externalWindow = nil;
        self.marqueeView = nil;
    }
}

- (void)initializeExternalScreen:(UIScreen *)screen
{
    if (self.externalWindow)
    {
        return;
    }
    self.externalWindow = [[UIWindow alloc] initWithFrame:[screen bounds]];

    self.externalWindow.screen = screen;
    
    self.marqueeView = [[[NSBundle mainBundle] loadNibNamed:@"MarqueeView" owner:self options:nil] firstObject];
    [self.marqueeView setFrame:self.externalWindow.frame];
    //UIView      *marqueeView = [[UIView alloc] initWithFrame:self.externalWindow.frame];
    [self.externalWindow addSubview:self.marqueeView];
    [self.externalWindow makeKeyAndVisible];
    self.marqueeView.transform = CGAffineTransformMakeRotation(M_PI);
    
    NSLog(@"image view: %@", self.marqueeView.imageView);
    
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    self.marqueeView.imageView.image = [UIImage imageNamed:@"altbeast.png"];
   
    self.marqueeView.audioPlot.backgroundColor = [UIColor blackColor];
    self.marqueeView.audioPlot.plotType = EZPlotTypeBuffer;
    self.marqueeView.audioPlot.shouldFill = YES;
    self.marqueeView.audioPlot.shouldMirror = YES;
    
    self.marqueeView.audioPlot.colors = @[
                                          [UIColor colorWithRed:1 green:0.467 blue:0 alpha:1],
                                          [UIColor blackColor],
                                          [UIColor colorWithRed:0.157 green:0.6 blue:0.765 alpha:1],
                                          [UIColor colorWithRed:0.125 green:0.675 blue:0.910 alpha:1],
                                          [UIColor colorWithRed:0.310 green:0.765 blue:0.341 alpha:1]
                                          ];

    self.marqueeView.audioPlot.color = [UIColor colorWithWhite:0.598 alpha:1.000];
    
    self.marqueeView.audioPlot.numOfBins = 24;
    [self.microphone startFetchingAudio];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI to
// work.
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that
    // mean? Because the audio is coming in as a stereo signal the data is split
    // into a left and right channel. So buffer[0] corresponds to the float*
    // data for the left channel while buffer[1] corresponds to the float* data
    // for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(), ^{
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources. Hence, one badass
        // line of code gets you a pretty plot :)
        [self.marqueeView.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
