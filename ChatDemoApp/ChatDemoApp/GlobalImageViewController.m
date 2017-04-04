//
//  GlobalImageViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 03/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GlobalImageViewController.h"

@interface GlobalImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *globalImageView;
@end

@implementation GlobalImageViewController
@synthesize globalImage;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.globalImageView.image=globalImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBAction
- (IBAction)cancelAction:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
