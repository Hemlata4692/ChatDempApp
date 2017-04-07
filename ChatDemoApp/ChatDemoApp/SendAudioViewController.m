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
#import "UserDefaultManager.h"

@interface SendAudioViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {

    BOOL isRed, isExceedSize;
    NSTimer *timer, *recordingTimer;
    int second, minute, continousSecond;
    float maxSize;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *audioFilePath;
}

@property (strong, nonatomic) IBOutlet UIImageView *micImageView;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *startPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation SendAudioViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self recordAudioFile];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [timer invalidate];
    timer=nil;
    [recordingTimer invalidate];
    recordingTimer=nil;
}
#pragma mark - end

#pragma mark - Intial setup of audio recording
- (void)recordAudioFile {
    
    self.doneButton.hidden=YES;
    isExceedSize=NO;
    isRed=false;
    second = 0;
    minute = 0;
    continousSecond = 0;
    maxSize=2.0;
    
    [self.startPauseButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    [self.startPauseButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateSelected];
    self.startPauseButton.selected=NO;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    
    //Set audio file path
    audioFilePath = [myDelegate getAudioFilePath];
    //Start AVAudio session for audio recording
    NSURL *outputFileURL = [NSURL URLWithString:audioFilePath];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
//    Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}
#pragma mark - end

#pragma mark - Set timer
//set recording timer in minutes and seconds
- (void)startRecordTimer {
    
    continousSecond++;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    
    if (recorder.recording) {
        
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
        //check if recording exceeds the given file size
        if (size >= (1024*1024*maxSize)) {
            
            [self.view makeToast:[NSString stringWithFormat:@"File size cannot exceed %.2f MB.",maxSize]];
            
            isExceedSize=YES;
            self.startPauseButton.selected=NO;
            [timer invalidate];
            timer=nil;
            [recordingTimer invalidate];
            recordingTimer=nil;
            [recorder stop];
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:NO error:nil];
        }
    }
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
    
    [myDelegate deleteCacheAudioFile:[audioFilePath lastPathComponent]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(UIButton *)sender {
    
    [recordingTimer invalidate];
    recordingTimer = nil;
    //stop recording if it is running and save answer
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    //stop playing the recording
    if ([player play]) {
        [player stop];
    }
    //Calculate length of answer
//    unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
    [self.delegate sendAudioDelegateAction:[audioFilePath lastPathComponent] timeDuration:self.timerLabel.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startPause:(UIButton *)sender {
    
    if (self.startPauseButton.isSelected) {
        
        self.startPauseButton.selected=NO;
        [timer invalidate];
        timer=nil;
        [recordingTimer invalidate];
        recordingTimer=nil;
        [recorder pause];
    }
    else {
        
        if (isExceedSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view makeToast:[NSString stringWithFormat:@"File size cannot exceed %.2f MB.",maxSize]];
            });
        }
        else {
            
            [recorder record];
            self.doneButton.hidden=NO;
            self.startPauseButton.selected=YES;
            timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(changeMicImage) userInfo:nil repeats:YES];
            recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(startRecordTimer)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
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
