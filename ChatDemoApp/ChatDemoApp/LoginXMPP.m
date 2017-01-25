//
//  LoginXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LoginXMPP.h"
#import "XMPPUserDefaultManager.h"

@interface LoginXMPP () {

    AppDelegateObjectFile *appDelegate;
}
@end

@implementation LoginXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Login User
- (void)loginConnectWithoutPassword:(NSString *)username {
    
    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%@@%@",username,appDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:appDelegate.defaultPassword key:@"PassCred"];
    [XMPPUserDefaultManager setValue:@"1" key:@"CountValue"];
    [appDelegate disconnect];
    [appDelegate connect];
}

- (void)loginConnectPassword:(NSString *)password username:(NSString *)username {
    
    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%@@%@",username,appDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:password key:@"PassCred"];
    [XMPPUserDefaultManager setValue:@"1" key:@"CountValue"];
    [appDelegate disconnect];
    [appDelegate connect];
}
#pragma mark - end

#pragma mark - Post notification called method
- (void)UserDidAuthenticated {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loginUserDidAuthenticatedResult];
    });
}

- (void)UserNotAuthenticated {
    
    [XMPPUserDefaultManager removeValue:@"LoginCred"];
    [XMPPUserDefaultManager removeValue:@"PassCred"];
    [self loginUserNotAuthenticatedResult];
}

//These method is called to subViewController of LoginXMPP file
- (void)loginUserDidAuthenticatedResult {}
- (void)loginUserNotAuthenticatedResult{}
//end
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
