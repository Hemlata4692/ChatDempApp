//
//  SendAudioViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 05/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "SendAudioViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface SendAudioViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {

    BOOL isRed;
    NSTimer *timer, *recordingTimer;
    int second, minute, hour, continousSecond;
    int maxSize;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *audioFilePath;
}

@property (strong, nonatomic) IBOutlet UIImageView *micImageView;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *startPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelAudioButton;
@end

@implementation SendAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {

    isRed=false;
    second = 0;
    minute = 0;
    continousSecond = 0;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(changeMicImage) userInfo:nil repeats:YES];
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(startRecordTimer)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [timer invalidate];
    timer=nil;
    [recordingTimer invalidate];
    recordingTimer=nil;
}

#pragma mark - Set timer
//set recording timer in minutes and seconds
- (void)startRecordTimer {
    continousSecond++;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
//    if (recorder.recording) {
//        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
//        //check if recording exceeds the given file size
//        if (size >= (1024*1024*maxSize)) {
//            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//            [alert showWarning:self title:@"Alert" subTitle:[NSString stringWithFormat:@"File size cannot exceed %d MB.",maxSize] closeButtonTitle:@"OK" duration:0.0f];
//            [recordingTimer invalidate];
//            recordingTimer = nil;
//            [recorder stop];
//            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//            [audioSession setActive:NO error:nil];
//            isLatestRecording=YES;
//            self.audioRecordingButton.selected=NO;
//        }
//    }
}
#pragma mark - end

- (void) changeMicImage {

    isRed=!isRed;
    if (isRed) {
        
        self.micImageView.image=[UIImage imageNamed:@"redMicrophone"];
    }
    else {
    
        self.micImageView.image=[UIImage imageNamed:@"microphone"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startPause:(UIButton *)sender {
    
    
}

- (IBAction)cancelAudio:(UIButton *)sender {
    
    
}

- (IBAction)stop:(UIButton *)sender {
    
    
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
