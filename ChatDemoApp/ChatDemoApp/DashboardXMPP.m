//
//  DashboardXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardXMPP.h"
#import "XMPPUserDefaultManager.h"

@interface DashboardXMPP (){
    
    AppDelegateObjectFile *appDelegate;
}
@end

@implementation DashboardXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInformation) name:@"UpdatedProfile" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User logout
- (void)userLogout {
    
    [appDelegate disconnect];
    [XMPPUserDefaultManager removeValue:@"LoginCred"];
    //    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",myDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager removeValue:@"PassCred"];
    //    [appDelegate connect];
}
#pragma mark - end

- (void)updateProfileInformation {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
